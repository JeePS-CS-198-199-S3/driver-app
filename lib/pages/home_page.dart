import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/bottom_nav_bar.dart';
import '../style/constants.dart';
import 'dashboard_page.dart';
import 'jeepney_page.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // navigate bottom bar
  int selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // pages
  final List<Widget> pages = [
    // Dashboard
    DashboardPage(),

    // Jeepney List Page
    JeepneyPage(),

    // Maps Page
    MapPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout)
          )
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: pages[selectedIndex]
    );
  }
}
