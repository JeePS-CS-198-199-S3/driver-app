import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../models/driver_emergency_model.dart';
import '../services/mapbox.dart';
import '../style/constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapboxMapController _mapController;
  late Timer _timer;
  late StreamSubscription driverEmergencySubscription;
  final CollectionReference driverEmergencyCollection = FirebaseFirestore.instance.collection('driver_emergency');
  List<DriverEmergency> emergencies = [];

  _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void listenToEmergencies() {
    driverEmergencySubscription = driverEmergencyCollection.snapshots().listen((QuerySnapshot snapshot) {
      setState(() {
        emergencies = snapshot.docs.map((doc) => DriverEmergency.fromSnapshot(doc)).toList();
      });
    });
  }

  void updateMapWithFilteredEmergencies() {
    // Filter emergencies based on the timestamp
    List<DriverEmergency> filteredEmergencies = emergencies
        .where((emergency) =>
    DateTime.now().difference(emergency.timestamp.toDate()).inSeconds < sosLifespan)
        .toList();

    // Update MapboxMap with the filtered emergencies
    updateMap(filteredEmergencies);
  }

  void updateMap(List<DriverEmergency> emergencies) {
    // Clear existing map markers
    _mapController.clearCircles();

    // Add red circles for each emergency
    for (DriverEmergency emergency in emergencies) {
      _mapController.addCircle(CircleOptions(
        geometry: LatLng(emergency.location.latitude, emergency.location.longitude),
        circleColor: '#F44336',
        circleRadius: 5.0,
        circleOpacity: 0.5
      ));
    }
  }


  @override
  void initState() {
    super.initState();
    listenToEmergencies();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) =>
    updateMapWithFilteredEmergencies());
  }

  @override
  void dispose() {
    driverEmergencySubscription.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapboxMap(
        accessToken: accessToken,
        initialCameraPosition: const CameraPosition(
            target: initialCameraPosition,
            zoom: zoom
        ),
        onMapCreated: _onMapCreated,
        styleString: mapStyle,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      )
    );
  }
}
