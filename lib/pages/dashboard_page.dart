import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/services/database_manager.dart';
import '../components/jeepney_page_loader.dart';
import '../components/loaded_dashboard_page.dart';
import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../style/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
          child: FutureBuilder<Driver?>(
            future: getDriverByEmail(user.email!),
            builder: (context, snapshot) {
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
                Driver driver = snapshot.data!;
                return FutureBuilder<Jeep?>(
                  future: getJeepById(driver.jeepDriving),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the Future is still running, show a loading indicator
                      return const JeepneyPageLoader();
                    } else if (snapshot.hasError || snapshot.data == null) {
                      // If there is an error, display an error message
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return LoadedDashboardPage(driver: driver, jeep: snapshot.data!);
                    }
                  },
                );
              }
            },
          ),
        ),
      )
    );
  }
}


