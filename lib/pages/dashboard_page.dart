import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/button.dart';
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

  @override
  void initState() {
    super.initState();

    setState(() {
      _driverAccount = widget.driverAccount;
    });

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
        });
      } else {
        setState(() {
          driverJeep = null;
        });
      }
    } else {
      setState(() {
        driverJeep = null;
      });
    }

    fetchRoute();
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
                Padding(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_driverAccount.jeep_driving == ""? "Select a PUV to Operate":_driverAccount.jeep_driving!),

                      const SizedBox(height: Constants.defaultPadding/3),

                      const Divider(color: Colors.white),

                      const SizedBox(height: Constants.defaultPadding/3),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: IconButtonBig(color: Colors.red, icon: const Icon(Icons.remove), function: () => print("enabled"), enabled: _driverAccount.jeep_driving != "")
                          ),
                          const SizedBox(width: Constants.defaultPadding*7),
                          Expanded(
                              child: IconButtonBig(color: Colors.green, icon: const Icon(Icons.add), function: () => print("enabled"), enabled: _driverAccount.jeep_driving != "")
                          ),
                        ],
                      ),

                      const SizedBox(height: Constants.defaultPadding/3),

                      const Divider(color: Colors.white),

                      const SizedBox(height: Constants.defaultPadding/3),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButtonBig(
                            color: driverRoute != null
                              ? Color(driverRoute!.routeColor)
                              : Colors.grey.withOpacity(0.2),
                            icon: const Icon(Icons.power_settings_new),
                            function: () => print("enabled"),
                            enabled: widget.driverAccount.jeep_driving != "",
                          ),
                          Row(
                            children: [
                              ImageButtonBig(imagePath: 'lib/images/accidentNoBG.png', color: const Color(0xffC62828), function: () {}, enabled: widget.driverAccount.jeep_driving != ""),

                              const SizedBox(width: Constants.defaultPadding/2),

                              ImageButtonBig(imagePath: 'lib/images/crimeNoBG.png', color: const Color(0xffC62828), function: () {}, enabled: widget.driverAccount.jeep_driving != ""),

                              const SizedBox(width: Constants.defaultPadding/2),

                              ImageButtonBig(imagePath: 'lib/images/mechErrorNoBG.png', color: const Color(0xffC62828), function: () {}, enabled: widget.driverAccount.jeep_driving != "")
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
                    icon: const Icon(Icons.directions_bus),
                    iconSize: 17,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero
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








