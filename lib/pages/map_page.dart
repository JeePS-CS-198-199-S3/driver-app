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
  List<DriverEmergencyCircle> emergencies = [];

  _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void listenToEmergencies() {
    driverEmergencySubscription = driverEmergencyCollection.snapshots().listen((QuerySnapshot snapshot) {
      setState(() {
        emergencies = snapshot.docs.map((doc) {
          DriverEmergency driverEmergency = DriverEmergency.fromSnapshot(doc);
          CircleOptions driverEmergencyCircle = CircleOptions(
              geometry: LatLng(driverEmergency.location.latitude, driverEmergency.location.longitude),
              circleColor: '#F44336',
              circleRadius: 5.0,
              circleOpacity: 0.5
          );
          return DriverEmergencyCircle(driverEmergency: driverEmergency, circleOptions: driverEmergencyCircle);
        }).toList();
      });
    });
  }

  void updateMapWithFilteredEmergencies() {
    // Filter emergencies based on the timestamp
    emergencies = emergencies
        .where((emergency) => DateTime.now().difference(emergency.driverEmergency.timestamp.toDate()).inSeconds < sosLifespan)
        .toList();

    // Update MapboxMap with the filtered emergencies
    updateMap();
  }

  void updateMap() {
    // Clear existing map markers
    _mapController.clearCircles();

    // Add red circles for each emergency
    for (DriverEmergencyCircle emergency in emergencies) {
      _mapController.addCircle(emergency.circleOptions);
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
