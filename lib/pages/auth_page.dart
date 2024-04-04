import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/style/constants.dart';

import '../services/device_location/request_permission.dart';
import 'home_page.dart';
import 'login_or_register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool gpsEnabled = false;

  @override
  void initState() {
    super.initState();

    checkPermissions();
  }

  Future<void> checkPermissions() async {
    bool result = await requestLocationPermission();

    setState(() {
      gpsEnabled = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gpsEnabled
        ? StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Logged in
          if(snapshot.hasData) {
            return HomePage(currentUserAuth: snapshot.data!);
          }

          // NOT logged in
          else {
            return const LoginOrRegisterPage();
          }
        },
      )
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, color: Colors.red[600], size: 50),
            const SizedBox(height: Constants.defaultPadding),
            const Text("Location Permission rejected", style: TextStyle(fontSize: 20)),
            const SizedBox(height: Constants.defaultPadding),
            const Text("JeePS Drivers App requires location tracking to function correctly. If you want to proceed, please enable location tracking permissions.", textAlign: TextAlign.center,),
                ]),
        )
    );
  }
}
