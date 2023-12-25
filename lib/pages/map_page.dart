import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../models/driver_emergency_model.dart';
import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../models/routes.dart';
import '../services/database_manager.dart';
import '../services/mapbox.dart';
import '../style/constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final user = FirebaseAuth.instance.currentUser!;

  late MapboxMapController _mapController;
  late Timer _timer;
  late StreamSubscription driverEmergencySubscription;
  final CollectionReference driverEmergencyCollection = FirebaseFirestore.instance.collection('driver_emergency');
  List<DriverEmergencyCircle> emergencies = [];
  List<DriverEmergencyCircle> inMap = [];

  _onMapCreated(MapboxMapController controller) {
    loadData();
    _mapController = controller;

    _mapController.onCircleTapped.add(_onCircleTapped);
  }

  _onMapStyleLoaded() {
    listenToEmergencies();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => updateMap());
  }

  void _onCircleTapped(Circle circle) {
    _mapController.updateCircle(circle, tappedDriverEmergency);
  }

  void listenToEmergencies() {
    driverEmergencySubscription = driverEmergencyCollection
        .where('timestamp', isGreaterThan: DateTime.now().subtract(const Duration(seconds: sosLifespan)))
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        emergencies = snapshot.docs.map((doc) {
          DriverEmergency driverEmergency = DriverEmergency.fromSnapshot(doc);
          return DriverEmergencyCircle(driverEmergency: driverEmergency,  driverEmergencyCircle: Circle("EmergencyCircle", CircleOptions(
            geometry: LatLng(driverEmergency.location.latitude, driverEmergency.location.longitude),
            circleColor: emergencyColors[driverEmergency.type],
            circleRadius: 7.0,
            circleOpacity: 0.5,
            ))
          );
        }).toList();
      });
      updateMap();
    });

  }

  // void updateMapWithFilteredEmergencies() {
  //   // Filter emergencies based on the timestamp
  //   print("listenToEmergencies: ${emergencies.length}");
  //   emergencies = emergencies
  //       .where((emergency) => DateTime.now().difference(emergency.driverEmergency.timestamp.toDate()).inSeconds < sosLifespan)
  //       .toList();
  //
  //   print("updateMapWithFilteredEmergencies: ${emergencies.length}");
  //   // Update MapboxMap with the filtered emergencies
  //
  // }

  void updateMap() {
    _mapController.clearCircles();

    // Add red circles for each emergency
    for (DriverEmergencyCircle emergency in emergencies) {
      if (DateTime.now().difference(emergency.driverEmergency.timestamp.toDate()).inSeconds < sosLifespan) {
        _mapController.addCircle(emergency.driverEmergencyCircle.options);
      }
    }
  }

  Driver? driver;
  Jeep? jeep;
  Routes? route;

  void addRoute(MapboxMapController controller) {
    List<LatLng> routeCoordinates = route!.routeCoordinates
        .map((geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude))
        .toList();

    // Add route polyline
    controller.addLine(LineOptions(
      geometry: routeCoordinates,
      lineColor: '#${route!.routeColor.toRadixString(16).toString().substring(2)}',
      lineWidth: 3.0,
    ));
  }

  Future<void> loadData() async {
    driver = await getDriverByEmail(user.email!);

    if (driver != null) {
      jeep = await getJeepById(driver!.jeepDriving);
    }

    if (jeep != null) {
      route = await getRouteById(jeep!.routeId);
    }

    setState(() {});

    if (route != null) {
      addRoute(_mapController);
    }

  }

  @override
  void initState() {
    super.initState();
    // Initialize variables to null
    driver = null;
    jeep = null;
    route = null;
  }


  @override
  void dispose() {
    driverEmergencySubscription.cancel();
    _timer.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MapboxMap(
              accessToken: accessToken,
              initialCameraPosition: const CameraPosition(
                  target: initialCameraPosition,
                  zoom: zoom
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onMapStyleLoaded,
              styleString: mapStyle,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Constants.bgColor
              ),
            )
          )
        ],
      )
    );
  }
}
