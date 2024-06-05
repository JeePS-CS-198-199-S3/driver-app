import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/drawer/account_widget.dart';
import 'package:transitrack_driver/models/account_model.dart';

import '../models/route_model.dart';
import '../style/constants.dart';

// Contains all the elements in the left drawer

class DrawerWidget extends StatelessWidget {
  AccountData? accountData;
  RouteData? route;
  DrawerWidget({super.key, required this.accountData, required this.route});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Constants.bgColor,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: Constants.defaultPadding * 3),
                const Image(
                  image: AssetImage('lib/images/icon.png'),
                  height: 150,
                ),
                const SizedBox(height: Constants.defaultPadding),
                const Divider(color: Colors.white),
                const SizedBox(height: Constants.defaultPadding),
                AccountStream(user: accountData, route: route),
                const SizedBox(height: Constants.defaultPadding),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: signUserOut,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}