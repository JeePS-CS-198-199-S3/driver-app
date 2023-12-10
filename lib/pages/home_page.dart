import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // navigate bottom bar
    int _selectedIndex = 0;
    void navigateBottomBar(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // pages
    final List<Widget> _pages = [
      // Dashboard


      // Jeepney List Page

    ];


    return Scaffold(
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
      body: Center(
        child: Text(
            "Logged In as ${user.email}."
        ),
      ),
    );
  }
}
