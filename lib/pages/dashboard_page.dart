import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/services/database_manager.dart';
import '../components/jeepney_page_loader.dart';
import '../components/loaded_dashboard_page.dart';
import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final user = FirebaseAuth.instance.currentUser!;

  Driver? driver;
  Jeep? jeep;
  Routes? route;

  Future<void> loadData() async {
    driver = await getDriverByEmail(user.email!);

    if (driver != null) {
      jeep = await getJeepById(driver!.jeepDriving);
    }

    if (jeep != null) {
      route = await getRouteById(jeep!.routeId);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Initialize variables to null
    driver = null;
    jeep = null;
    route = null;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
          child: driver == null && jeep == null && route == null
              ? const Center(child: CircularProgressIndicator())
              : driver?.jeepDriving == ""
                ? const Center(child: Text("No Jeep Selected.", style: TextStyle(color: Colors.white)))
                : LoadedDashboardPage(driver: driver!, jeep: jeep!, route: route!)
        ),
      ),
    );
  }
}




