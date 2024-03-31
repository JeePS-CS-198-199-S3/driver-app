import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/map_widget.dart';
import '../components/icon_button_big.dart';
import '../components/image_button_big.dart';
import '../components/jeeps_list_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: MapWidget(),
          ),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: IconButtonBig(color: Colors.red, icon: const Icon(Icons.remove), function: () => decrement(), enabled: _driverAccount.jeep_driving != "")
                          ),
                          const SizedBox(width: Constants.defaultPadding*10),
                          Expanded(
                              child: IconButtonBig(color: Colors.green, icon: const Icon(Icons.add), function: () => increment(), enabled: _driverAccount.jeep_driving != "")
                          ),
                        ],
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
                      AwesomeDialog(
                        context: context,
                        keyboardAware: false,
                        dialogType: DialogType.noHeader,
                        body: JeepsListWidget(accountData: _driverAccount)
                      ).show();
                    },
                    icon: const Text("PUV LIST"),
                    iconSize: 17,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding)
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







