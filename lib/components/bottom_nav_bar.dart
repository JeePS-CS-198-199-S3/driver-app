import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../style/constants.dart';

class BottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  BottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
      child: GNav(
        onTabChange: (value) => onTabChange!(value),
        color: Colors.white,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        activeColor: Colors.white,
        tabBackgroundColor: Constants.secondaryColor,
        tabBorderRadius: 24,
        tabActiveBorder: Border.all(
          color: Colors.white,
        ),
        tabs: const [
        GButton(
          icon: Icons.dashboard,
          text: 'Dashboard',
        ),
        GButton(
          icon: Icons.directions_bus,
          text: 'Jeeps',
        ),
        GButton(
          icon: Icons.map,
          text: 'Map',
        ),
      ]),
    );
  }
}
