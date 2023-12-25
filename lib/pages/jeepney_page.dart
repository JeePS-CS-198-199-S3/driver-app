import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/jeep_tile.dart';

import '../components/jeepney_page_loader.dart';
import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../models/routes.dart';
import '../services/database_manager.dart';
import '../style/constants.dart';

class JeepneyPage extends StatefulWidget {
  const JeepneyPage({super.key});

  @override
  State<JeepneyPage> createState() => _JeepneyPageState();
}

class _JeepneyPageState extends State<JeepneyPage> {
  final user = FirebaseAuth.instance.currentUser!;

  Driver? currentDriver;
  late List<Driver?> driverList;
  late List<Jeep?> jeepList;
  Jeep? jeep;
  Routes? route;
  List<String>? occupiedJeeps;

  Future<void> loadData() async {
    driverList = await getDrivers();

    setDriver(driverList.firstWhere((driver) => driver?.email == user.email)!);

    jeep = await getJeepById(currentDriver!.jeepDriving);

    occupiedJeeps = driverList.map((driver) => driver!.jeepDriving).toList();

    jeepList = await getJeepsFromFirestore(currentDriver!.jeepDriving==""?-1:jeep!.routeId);

    if (currentDriver!.jeepDriving != "") {
      route = await getRouteById(jeep!.routeId);
    }
    setState(() {});
  }

  void setDriver(Driver driver) {
    currentDriver = driver;
  }

  Future<void> rideJeep(String email, String newJeep) async {
    await updateJeepDriving(email, newJeep);
    _refresh();
  }

  Future<void> _refresh() async {
    loadData();
  }

  @override
  void initState() {
    super.initState();
    // Initialize variables to null
    driverList = [];
    jeepList = [];
    currentDriver = null;
    jeep = null;
    route = null;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
          child: SizedBox(
              width: double.maxFinite,
              child: currentDriver == null
                  ? const Center(child: CircularProgressIndicator(),)
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDriver!.jeepDriving!=""?"Jeepneys in ${route!.routeName}":"Available Jeepneys",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),
                  ),
                  const SizedBox(height: Constants.defaultPadding),
                  Expanded(
                    child: ListView.builder(
                      itemCount: jeepList.length,
                      itemBuilder: (context, index) {
                        Jeep jeep = jeepList[index]!;

                        String driver = "Vacant";

                        for (int i = 0; i < driverList.length; i++) {
                          if (driverList[i]!.jeepDriving == jeep.id) {
                            driver = driverList[i]!.name;
                            break;
                          }
                        }

                        return JeepTile(
                          driver: driver,
                            jeep: jeep,
                            onPressed: () {
                              if (jeep.id == currentDriver!.jeepDriving) {
                                AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.scale,
                                    title: "Leaving Jeep",
                                    desc: "Please confirm leaving Jeep\nwith plate number\n${jeep.id}.",
                                    btnCancelOnPress: (){},
                                    btnOkOnPress: () => rideJeep(currentDriver!.email, ""),
                                    btnOkColor: Colors.green[400],
                                    btnOkText: "Confirm"
                                ).show();
                              } else if (occupiedJeeps!.contains(jeep.id)) {
                                AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.scale,
                                    title: "Jeep is Occupied!",
                                    desc: "Please find a vacant jeepney to ride.",
                                    btnCancelOnPress: (){},
                                    btnOkOnPress: (){},
                                    btnOkColor: Colors.green[400],
                                    btnOkText: "Okay"
                                ).show();
                              } else {
                                AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.question,
                                    animType: AnimType.scale,
                                    title: "Drive Jeep",
                                    desc: "This jeepney is available. Please confirm your occupation to Jeep with plate number\n${jeep.id}.",
                                    btnCancelOnPress: (){},
                                    btnOkOnPress: () => rideJeep(currentDriver!.email, jeep.id),
                                    btnOkColor: Colors.green[400],
                                    btnOkText: "Confirm"
                                ).show();
                              }
                            }
                        );
                      },
                    ),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}

