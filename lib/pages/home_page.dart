import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/drawer_widget.dart';
import '../models/account_model.dart';
import '../style/constants.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  final User currentUserAuth;
  const HomePage({super.key, required this.currentUserAuth});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Local user from firestore
  AccountData? currentUserFirestore;
  late StreamSubscription userFirestoreStream;

  @override
  void initState() {
    super.initState();
    listenToUserFirestore();
  }

  void listenToUserFirestore() {
    userFirestoreStream = FirebaseFirestore.instance
        .collection('accounts')
        .where('account_email', isEqualTo: widget.currentUserAuth.email!)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          currentUserFirestore = AccountData.fromSnapshot(snapshot.docs.first);
        });
      }
    });
  }

  @override
  void dispose() {
    userFirestoreStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.bgColor,
        appBar: AppBar(
          backgroundColor: Constants.bgColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: DrawerWidget(accountData: currentUserFirestore),
        body: currentUserFirestore != null
            ? DashboardPage(driverAccount: currentUserFirestore!)
            : const Center(child: CircularProgressIndicator())
    );
  }
}

