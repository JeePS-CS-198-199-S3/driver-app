import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/map_widget.dart';
import '../components/header.dart';
import '../components/icon_button_big.dart';
import '../components/image_button_big.dart';
import '../models/account_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class DashboardPage extends StatefulWidget {
  final AccountData driverAccount;
  const DashboardPage({super.key, required this.driverAccount});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late AccountData _driverAccount;
  JeepData? driverJeep;
  RouteData? driverRoute;

  int operateModeChoice = 0;
  List<OperationModes> operateModes = [OperationModes(name: "Passive", color: Colors.red), OperationModes(name: "Semi-Active", color: Colors.orange), OperationModes(name: "Active", color: Colors.green)];

  int passengers = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      _driverAccount = widget.driverAccount;
    });

    if (_driverAccount.jeep_driving != null) {
      fetchJeep();
    }

    checkAccountType();
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

  void checkAccountType() {
    if (widget.driverAccount.account_type != 1) {
      Future.delayed(const Duration(seconds: 1), () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          desc: 'This app is only intended for the JeePS drivers. Please use a driver account.',
          onDismissCallback: (_) => FirebaseAuth.instance.signOut(),
        ).show();
      });
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

        fetchRoute();
      } else {
        setState(() {
          driverJeep = null;
        });
      }
    } else {
      setState(() {
        driverJeep = null;
        driverRoute = null;
      });
    }
  }

  void fetchRoute() async {
    RouteData? routeData = await RouteData.fetchRouteData(driverJeep!.route_id);

    if (routeData != null) {
      setState(() {
        driverRoute = routeData;
      });
    } else {
      setState(() {
        driverRoute = null;
      });
    }
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Header(driverAccount: _driverAccount),

          Expanded(
            child: MapWidget(),
          ),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                if (operateModeChoice == 2)
                  PieChart(
                    swapAnimationDuration: Duration.zero,
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -180,
                      sections: [
                        PieChartSectionData(
                          color: driverJeep != null && driverRoute != null? Color(driverRoute!.routeColor) : Colors.grey.withOpacity(0.3),
                          value: driverJeep != null && driverRoute != null? passengers.toDouble() : 10,
                          showTitle: false,
                          radius: 10,
                        ),
                        PieChartSectionData(
                          color: driverJeep != null && driverRoute != null? Color(driverRoute!.routeColor) : Colors.grey.withOpacity(0.5)
                              .withOpacity(0.1),
                          value: driverJeep != null && driverRoute != null? driverJeep!.max_capacity - passengers.toDouble() : 0,
                          showTitle: false,
                          radius: 10,
                        ),
                        PieChartSectionData(
                          color: Colors.transparent,
                          value: driverJeep != null && driverRoute != null? driverJeep!.max_capacity.toDouble(): 10,
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
                                      text: driverJeep != null && driverRoute != null? '\noperating' : "\na PUV",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        fontSize: 15,
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
                      Text(driverJeep == null? "Select a PUV to Operate":driverJeep!.device_id),

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
                                enabled: _driverAccount.jeep_driving != ""
                              )
                              : IconButtonBig(
                                color: Colors.red,
                                icon: const Icon(Icons.remove),
                                function: () => decrement(),
                                enabled: _driverAccount.jeep_driving != ""
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
                                enabled: _driverAccount.jeep_driving != ""
                            )
                            : IconButtonBig(
                                color: Colors.green,
                                icon: const Icon(Icons.add),
                                function: () => increment(),
                                enabled: _driverAccount.jeep_driving != ""
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
                          WidgetButtonBig(widget: const Center(child:  Text("LEAVE\nPUV", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900))), color: driverRoute != null
                              ? Color(driverRoute!.routeColor)
                              : Colors.grey.withOpacity(0.2), function: () => updateDriverJeep(widget.driverAccount.account_email, ""), enabled: widget.driverAccount.jeep_driving != ""),
                          Row(
                            children: [
                              WidgetButtonBig(widget: Image.asset('lib/images/accidentNoBG.png', fit: BoxFit.cover), color: const Color(0xffC62828), function: () {}, enabled: widget.driverAccount.jeep_driving != ""),

                              const SizedBox(width: Constants.defaultPadding/2),

                              WidgetButtonBig(widget: Image.asset('lib/images/crimeNoBG.png', fit: BoxFit.cover), color: const Color(0xffC62828), function: () {}, enabled: widget.driverAccount.jeep_driving != ""),

                              const SizedBox(width: Constants.defaultPadding/2),

                              WidgetButtonBig(widget: Image.asset('lib/images/mechErrorNoBG.png', fit: BoxFit.cover), color: const Color(0xffC62828), function: () {}, enabled: widget.driverAccount.jeep_driving != "")
                            ],
                          )
                        ],
                      )
                    ]
                  )
                ),
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
                    tooltip: "Active: Increment/Decrement Passenger Count\nSemi-Active: Full/Not Full Passenger Count\nPassive: Only Location Tracking",
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







