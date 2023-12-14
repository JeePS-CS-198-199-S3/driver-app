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
  final user = FirebaseAuth.instance.currentUser!;

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
    const DashboardPage(),

    // Jeepney List Page
    const JeepneyPage(),

    // Maps Page
    const MapPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      drawer: Drawer(
        backgroundColor: Constants.bgColor,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Constants.defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: Constants.defaultPadding*3),

                  Icon(Icons.directions_bus, size: 150, color: Colors.white),

                  SizedBox(height: Constants.defaultPadding*3),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white,),
                    title: Text("Logout", style: TextStyle(color: Colors.white),),
                    onTap: signUserOut,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: pages[selectedIndex]
    );
  }
}
