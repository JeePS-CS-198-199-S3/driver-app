import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/jeep_tile.dart';

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
  String data = 'Initial Data';

  Future<void> fetchData() async {
    // Simulate fetching data from an API or other source
    await Future.delayed(Duration(seconds: 2));
    // Update the data
    setState(() {
      data = 'New Data';
    });
  }

  Future<void> rideJeep(String email, Jeep newJeep) async {
    await updateJeepDriving(email, newJeep.id);
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<Driver?>(
            future: getDriverByEmail(user.email!),
            builder: (context, snapshot) {
              int route = -1;
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the Future is still running, show a loading indicator
                return Center(child: CircularProgressIndicator());
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
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // If there is an error, display an error message
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        route = snapshot.data!.routeId;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route >= 0?"Jeepneys in ${ routes[route]}":"Jeepneys in all routes",
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white
                          ),
                        ),

                        const SizedBox(height: Constants.defaultPadding),

                        Expanded(
                          child: FutureBuilder<List<Jeep>>(
                            future: getJeepsFromFirestore(route),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));
                              } else {
                                List<Jeep> jeeps = snapshot.data ?? [];
                                return ListView.builder(
                                  itemCount: jeeps.length,
                                  itemBuilder: (context, index) {
                                    Jeep jeep = jeeps[index];
                                    return JeepTile(
                                      jeep: jeep,
                                      onPressed: () => rideJeep(driver.email, jeep),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        )
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
