import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_driver/components/map_widget.dart';
import 'package:transitrack_driver/models/jeep_driver_model.dart';
import 'package:transitrack_driver/services/account_verification.dart';
import '../components/header.dart';
import '../components/icon_button_big.dart';
import '../components/image_button_big.dart';
import '../models/account_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../services/format_time.dart';
import '../services/send_report.dart';
import '../style/constants.dart';

// Main Page of the App

class DashboardPage extends StatefulWidget {
  final AccountData driverAccount;
  const DashboardPage({super.key, required this.driverAccount});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late AccountData _driverAccount;
  LocationData? deviceLocation;

  JeepData? driverJeep;

  StreamSubscription? routeListener;
  RouteData? driverRoute;

  int operateModeChoice = 2;
  List<OperationModes> operateModes = [
    OperationModes(name: "Passive", color: Colors.red),
    OperationModes(name: "Semi-Active", color: Colors.orange),
    OperationModes(name: "Active", color: Colors.green)
  ];


  int passengers = 0;

  @override
  void initState() {
    super.initState();

    checkAccountType(context, widget.driverAccount);

    setState(() {
      _driverAccount = widget.driverAccount;
    });

    if (_driverAccount.jeep_driving != "") {
      fetchJeep();
    }
  }


  @override void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_driverAccount != widget.driverAccount) {

      // Save previous driverAccount state
      AccountData prev = _driverAccount;

      setState(() {
        _driverAccount = widget.driverAccount;
      });

      // Check if we have changes in the jeep_driving field so we can load the latest jeepData.
      if (prev.jeep_driving != _driverAccount.jeep_driving) {
        fetchJeep();
      }
    }
  }



  void fetchJeep() async {
    if (_driverAccount.jeep_driving != "") {

      JeepData? jeepData = await fetchJeepData(_driverAccount.jeep_driving!);

      if (jeepData != null) {
        setState(() {
          driverJeep = jeepData;
          passengers = driverJeep!.passenger_count;
        });

        FlutterBackgroundService().startService();

        if (passengers == -2) {
          setState(() {
            operateModeChoice = 0;
          });
        } else if (passengers == -1) {
          setState(() {
            operateModeChoice = 1;
          });
        } else {
          setState(() {
            operateModeChoice = 2;
          });
        }

        listenToRoute();
      } else {
        setState(() {
          driverJeep = null;
        });

        FlutterBackgroundService().invoke("stopService");
      }
    } else {
      setState(() {
        driverJeep = null;
        routeListener?.cancel();
        driverRoute = null;
      });
      FlutterBackgroundService().invoke("stopService");
    }
  }

  void listenToRoute() async {
    routeListener = FirebaseFirestore.instance
        .collection('routes')
        .where('route_id', isEqualTo: driverJeep!.route_id)
        .limit(1)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          driverRoute =
              snapshot.docs.map((doc) => RouteData.fromFirestore(doc)).first;
        });
      } else {
        setState(() {
          driverRoute = null;
        });
      }
    });
  }

  void increment() {
    if (passengers < driverJeep!.max_capacity) {

      setState(() {
        passengers++;
      });
    }
  }

  void decrement() {
    if (passengers > 0) {
      setState(() {
        passengers--;
      });
    }
  }

  void full() {
    setState(() {
      passengers = driverJeep!.max_capacity;
    });
  }

  void notFull() {
    setState(() {
      passengers = -1;
    });
  }

  @override
  void dispose() {
    routeListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Header(driverAccount: _driverAccount, routeData: driverRoute),

          const Divider(color: Colors.white, height: 0, indent: Constants.defaultPadding, endIndent: Constants.defaultPadding),

          SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding, vertical: Constants.defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Regular Fare: ${driverRoute != null? "Php ${driverRoute!.routeFare}" : "NA"}", style: const TextStyle(fontSize: 10)),

                  if (driverRoute != null)
                  Text(formatTime(driverRoute!.routeTime), style: const TextStyle(fontSize: 10)),

                  Text("Discounted: ${driverRoute != null? "Php ${driverRoute!.routeFareDiscounted}" : "NA"}", style: const TextStyle(fontSize: 10))
                ]
              ),
            )
          ),

          Expanded(
            child: MapWidget(
              driverData: _driverAccount,
              key: mapWidgetKey,
              routeData: driverRoute,
              jeepLocation: (LocationData jeepLocation) {
                setState(() {
                  deviceLocation = jeepLocation;
                });
                try {
                  JeepData.updateJeepFirestore(driverJeep!.device_id, {
                    'location': GeoPoint(deviceLocation!.latitude!, deviceLocation!.longitude!),
                    'bearing': deviceLocation!.heading,
                    'passenger_count': passengers,
                    'timestamp': FieldValue.serverTimestamp()
                  });
                } catch (e) {
                  print("Error: ${e.toString()}");
                }

                try {
                  // Add a new document with auto-generated ID
                  FirebaseFirestore.instance
                      .collection('jeeps_historical')
                      .add({
                    'location': GeoPoint(jeepLocation.latitude!, jeepLocation.longitude!),
                    'bearing': jeepLocation.heading,
                    'passenger_count': passengers,
                    'timestamp': FieldValue.serverTimestamp(),
                    'device_id': driverJeep!.device_id,
                    'max_capacity': driverJeep!.max_capacity,
                    'route_id': driverJeep!.route_id,
                    'driver': _driverAccount.account_name,
                    'is_operating': true
                  });
                } catch (e) {
                  // pop loading circle
                  print("Error: ${e.toString()}");
                }
              }
            ),
          ),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                if (operateModeChoice == 2 && driverJeep != null && driverRoute != null)
                  PieChart(
                    swapAnimationDuration: Duration.zero,
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -180,
                      sections: [
                        PieChartSectionData(
                          color: Color(driverRoute!.routeColor),
                          value: passengers.toDouble(),
                          showTitle: false,
                          radius: 10,
                        ),
                        PieChartSectionData(
                          color: Colors.grey.withOpacity(0.1),
                          value: driverJeep!.max_capacity - passengers.toDouble(),
                          showTitle: false,
                          radius: 10,
                        ),
                        PieChartSectionData(
                          color: Colors.transparent,
                          value: driverJeep!.max_capacity.toDouble(),
                          showTitle: false,
                          radius: 10,
                        ),
                      ],
                    ),
                  ),
                if (operateModeChoice == 2)
                  Column(
                    children: [
                      Center(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  height: Constants
                                      .defaultPadding*5.3),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: driverJeep != null && driverRoute != null? '$passengers' : "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                      driverJeep != null && driverRoute != null? "/${driverJeep!.max_capacity}" : "Select",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: driverJeep != null && driverRoute != null? '\npassengers' : "\na PUV",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (driverJeep == null || driverRoute == null)
                      const Text( "Select a PUV to Operate"),

                      if (driverJeep != null && driverRoute != null)
                        Text(driverJeep!.device_id),

                      const SizedBox(height: Constants.defaultPadding/3),

                      const Divider(color: Colors.white),

                      const SizedBox(height: Constants.defaultPadding/3),

                      if (operateModeChoice != 0)
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: operateModeChoice == 1
                              ? WidgetButtonBig(
                                widget: const Center(
                                  child: Text("FULL"),
                                ),
                                isLong: false,
                                color: Colors.red,
                                function: () => full(),
                                enabled: driverRoute != null && driverJeep != null
                              )
                              : IconButtonBig(
                                color: Colors.red,
                                icon: const Icon(Icons.remove),
                                function: () => decrement(),
                                enabled: driverRoute != null && driverJeep != null
                              )
                          ),
                          SizedBox(width: Constants.defaultPadding*10,
                            child: operateModeChoice == 1
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("PUV is currently"),
                                  Text(
                                    passengers == -1
                                      ? "AVAILABLE"
                                      : "FULL",
                                    style: TextStyle(
                                      color: passengers == -1
                                        ? Colors.green
                                        : Colors.red
                                    )
                                  )
                                ],
                              )
                              : const SizedBox()
                          ),
                          Expanded(
                            child: operateModeChoice == 1
                            ? WidgetButtonBig(
                                widget: const Center(
                                  child: Text("AVAILABLE"),
                                ),
                                isLong: false,
                                color: Colors.green,
                                function: () => notFull(),
                                enabled: driverRoute != null && driverJeep != null
                            )
                            : IconButtonBig(
                                color: Colors.green,
                                icon: const Icon(Icons.add),
                                function: () => increment(),
                                enabled: driverRoute != null && driverJeep != null
                            )
                          ),
                        ],
                      ),

                      if (operateModeChoice == 0)
                        const SizedBox(
                          height: 73,
                          child: Center(
                            child: Text("BROADCAST MODE IS PASSIVE.\nPASSENGER COUNTING IS DISABLED.", textAlign: TextAlign.center),
                          ),
                        ),

                      const SizedBox(height: Constants.defaultPadding/3),

                      const Divider(color: Colors.white),

                      const SizedBox(height: Constants.defaultPadding/3),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WidgetButtonBig(
                            widget: Center(
                              child:  Text(
                                "LEAVE\nPUV",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: driverRoute != null && driverJeep != null
                                    ? Color(driverRoute!.routeColor)
                                    : Colors.grey
                                )
                              )
                            ),
                            color: driverRoute != null && driverJeep != null
                              ? Color(driverRoute!.routeColor)
                              : Colors.grey.withOpacity(0.2),
                            outLined: true,
                            function: () {
                              setState(() {
                                operateModeChoice = 2;
                              });
                              try {
                                // Add a new document with auto-generated ID
                                FirebaseFirestore.instance
                                    .collection('jeeps_historical')
                                    .add({
                                  'location': GeoPoint(deviceLocation!.latitude!, deviceLocation!.longitude!),
                                  'bearing': deviceLocation!.heading!,
                                  'passenger_count': passengers,
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'device_id': driverJeep!.device_id,
                                  'max_capacity': driverJeep!.max_capacity,
                                  'route_id': driverJeep!.route_id,
                                  'driver': _driverAccount.account_name,
                                  'is_operating': false
                                });
                              } catch (e) {
                                // pop loading circle
                                print("Error: ${e.toString()}");
                              }
                              updateDriverJeep(widget.driverAccount.account_email, {'jeep_driving': ""});
                            },
                            enabled: widget.driverAccount.jeep_driving != ""
                          ),
                          Stack(
                            children: [
                              Row(
                                children: [
                                  WidgetButtonBig(
                                    widget: Image.asset('lib/images/accidentNoBG.png',
                                        fit: BoxFit.cover),
                                    color: const Color(0xffC62828),
                                    function: () {
                                      sendReport(context, JeepDriverData(jeepData: driverJeep!, driverData: _driverAccount), 3).then((value) {
                                        if (value && deviceLocation != null) {
                                          mapWidgetKey.currentState?.rippleReport(LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!));
                                        }
                                      });
                                    },
                                    enabled: driverRoute != null && driverJeep != null,
                                    timed: true,
                                  ),

                                  const SizedBox(width: Constants.defaultPadding/2),

                                  WidgetButtonBig(
                                    widget: Image.asset('lib/images/crimeNoBG.png',
                                      fit: BoxFit.cover),
                                    color: const Color(0xffC62828),
                                    function: () {
                                      sendReport(context, JeepDriverData(jeepData: driverJeep!, driverData: _driverAccount), 1).then((value) {
                                        if (value && deviceLocation != null) {
                                          mapWidgetKey.currentState?.rippleReport(LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!));
                                        }
                                      });
                                    },
                                    enabled: driverRoute != null && driverJeep != null,
                                    timed: true,
                                  ),

                                  const SizedBox(width: Constants.defaultPadding/2),

                                  WidgetButtonBig(
                                    widget: Image.asset('lib/images/mechErrorNoBG.png',
                                      fit: BoxFit.cover),
                                    color: const Color(0xffC62828),
                                    function: () {
                                      sendReport(context, JeepDriverData(jeepData: driverJeep!, driverData: _driverAccount), 2).then((value) {
                                        if (value && deviceLocation != null) {
                                          mapWidgetKey.currentState?.rippleReport(LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!));
                                        }
                                      });
                                    },
                                    enabled: driverRoute != null && driverJeep != null,
                                    timed: true
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ]
                  )
                ),

                if (driverJeep != null && driverRoute != null)
                Positioned(
                  top: Constants.defaultPadding/4,
                  right: Constants.defaultPadding/4,
                  child: IconButton(
                    onPressed: () {
                      if (operateModeChoice < 2) {
                        setState(() {
                          operateModeChoice++;
                        });
                      } else {
                        setState(() {
                          operateModeChoice = 0;
                        });
                      }

                      if (operateModeChoice == 0) {
                        setState(() {
                          passengers = -2;
                        });
                      } else if (operateModeChoice == 1 && passengers < driverJeep!.max_capacity) {
                        setState(() {
                          passengers = -1;
                        });
                      } else if (passengers < driverJeep!.max_capacity){
                        setState(() {
                          passengers = 0;
                        });
                      }
                    },
                    icon: Row(
                      children: [
                        const Text("Broadcast Mode: "),
                        Text(operateModes[operateModeChoice].name, style: TextStyle(color: operateModes[operateModeChoice].color)),
                      ],
                    ),
                    iconSize: 17,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
                    tooltip: "Active: (-/+) Passenger Counting\nSemi-Active: (Full/Available) Passenger Counting\nPassive: Only Location Tracking",
                  )
                )
              ],
            )
          ),
        ],
      )
    );
  }
}

class TopClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, 110); // Clip to top 120 pixels
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}

class OperationModes {
  String name;
  Color color;

  OperationModes({
    required this.name,
    required this.color
});
}