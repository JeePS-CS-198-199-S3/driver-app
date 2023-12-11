import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/jeep_tile.dart';

import '../components/jeepney_page_loader.dart';
import '../models/driver_model.dart';
import '../models/jeep_model.dart';
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

  Future<void> rideJeep(String email, String newJeep) async {
    await updateJeepDriving(email, newJeep);
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
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
            child: FutureBuilder<Driver?>(
              future: getDriverByEmail(user.email!),
              builder: (context, snapshot) {
                int route = -1;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the Future is still running, show a loading indicator
                  return const JeepneyPageLoader();
                } else if (snapshot.hasError) {
                  // If there is an error, display an error message
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  // If no data is available, display a message indicating that the driver was not found
                  return Center(child: Text('Driver not found with email: ${user.email}'));
                } else {
                  // If the data is available, display the driver information
                  Driver driver = snapshot.data!;

                  return FutureBuilder<Jeep?>(
                    future: getJeepById(driver.jeepDriving),
                    builder: (context, snapshot) {
                      if (driver.jeepDriving != "") {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // While the Future is still running, show a loading indicator
                          return const JeepneyPageLoader();
                        } else if (snapshot.hasError) {
                          // If there is an error, display an error message
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          route = snapshot.data!.routeId;
                        }
                      }
                      return FutureBuilder<List<Jeep>>(
                        future: getJeepsFromFirestore(route),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting || false) {
                            return const JeepneyPageLoader();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));
                          } else {
                            List<Jeep> jeeps = snapshot.data ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route >= 0?"Jeepneys in ${routes[route]}":"Jeepneys in all routes",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                  ),
                                ),
                                const SizedBox(height: Constants.defaultPadding),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: jeeps.length,
                                    itemBuilder: (context, index) {
                                      Jeep jeep = jeeps[index];
                                      return JeepTile(
                                          jeep: jeep,
                                          onPressed: () {
                                            if (jeep.id == driver.jeepDriving) {
                                              AwesomeDialog(
                                                  context: context,
                                                  dialogType: DialogType.error,
                                                  animType: AnimType.scale,
                                                  title: "Leaving Jeep",
                                                  desc: "Please confirm leaving Jeep\nwith plate number\n${jeep.id}.",
                                                  btnCancelOnPress: (){},
                                                  btnOkOnPress: () => rideJeep(driver.email, ""),
                                                  btnOkColor: Colors.green[400],
                                                  btnOkText: "Confirm"
                                              ).show();
                                            } else {
                                              AwesomeDialog(
                                                  context: context,
                                                  dialogType: DialogType.question,
                                                  animType: AnimType.scale,
                                                  title: "Drive Jeep",
                                                  desc: "This jeepney is available. Please confirm your occupation to Jeep with plate number\n${jeep.id}.",
                                                  btnCancelOnPress: (){},
                                                  btnOkOnPress: () => rideJeep(driver.email, jeep.id),
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
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

