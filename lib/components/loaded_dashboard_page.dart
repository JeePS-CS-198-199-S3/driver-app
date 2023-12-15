import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../models/routes.dart';
import '../style/constants.dart';

class LoadedDashboardPage extends StatefulWidget {
  final Driver driver;
  final Jeep jeep;
  const LoadedDashboardPage({super.key, required this.driver, required this.jeep});

  @override
  State<LoadedDashboardPage> createState() => _LoadedDashboardPageState();
}

class _LoadedDashboardPageState extends State<LoadedDashboardPage> {
  late int _passengerCount;
  late bool _isOperating;
  late Timer _timer;
  final updateInterval = 3;

  // for location
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData? _locationData;

  void addPassenger(){
    if(_passengerCount < widget.jeep.maxCapacity) {
      setState(() {
        _passengerCount++;
      });
    }
  }

  void removePassenger(){
    if(_passengerCount > 0) {
      setState(() {
        _passengerCount--;
      });
    }
  }

  void sendLocation(){
    CollectionReference driverEmergencyCollection = FirebaseFirestore.instance.collection('driver_emergency');
    driverEmergencyCollection.add({
      'location': GeoPoint(_locationData!.latitude!, _locationData!.longitude!),
      'timestamp': FieldValue.serverTimestamp(),
      'jeep_id': widget.jeep.id,
      'driver_name': widget.driver.name,
      'route_id': widget.jeep.routeId
    });
  }

  void updateFirestoreJeep(String deviceId) async {
    // _getLocation();
    CollectionReference jeepsCollection = FirebaseFirestore.instance.collection('jeeps_realtime');
    // Query for the document with the specified device_id
    QuerySnapshot querySnapshot = await jeepsCollection.where('device_id', isEqualTo: deviceId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update the attributes of the document
      DocumentSnapshot document = querySnapshot.docs.first;
      if (_isOperating) {
        if (_locationData?.heading != 0) {
          jeepsCollection.doc(document.id).update({
            'passenger_count': _passengerCount,
            'slots_remaining': widget.jeep.maxCapacity-_passengerCount,
            'timestamp':  FieldValue.serverTimestamp(),
            'is_active': _isOperating,
            'location': GeoPoint(_locationData!.latitude!, _locationData!.longitude!),
            'bearing': _locationData!.heading
          });
        } else {
          jeepsCollection.doc(document.id).update({
            'passenger_count': _passengerCount,
            'slots_remaining': widget.jeep.maxCapacity-_passengerCount,
            'timestamp':  FieldValue.serverTimestamp(),
            'is_active': _isOperating,
            'location': GeoPoint(_locationData!.latitude!, _locationData!.longitude!)
          });
        }
      } else {
        jeepsCollection.doc(document.id).update({
          'is_active': _isOperating
        });
      }
    } else {
      print('Document with device_id $deviceId not found.');
    }
  }


  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _configureLocationSettings();
    _startLocationTracking();
  }

  void _configureLocationSettings() {
    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 2500,
      distanceFilter: 5,
    );
  }

  void _startLocationTracking() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _locationData = currentLocation;
      });
    });
  }

  @override
  void initState() {
    _passengerCount = widget.jeep.passengerCount;
    _isOperating = widget.jeep.isOperating;

    super.initState();
    _checkLocationPermission();
    // _getLocation();
    _timer = Timer.periodic(Duration(seconds: updateInterval), (Timer t) => updateFirestoreJeep(widget.jeep.id));
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
            "Logged in as ${widget.driver.email}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14
            )
        ),

        const SizedBox(height: Constants.defaultPadding*4),

        Text(
            "$_passengerCount/${widget.jeep.maxCapacity}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 75,
                fontWeight: FontWeight.bold
            )
        ),
        const Text(
            "passengers",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            )
        ),

        const SizedBox(height: Constants.defaultPadding*4),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isOperating?addPassenger:(){},
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: _isOperating?Colors.white:Colors.white.withOpacity(0.4),
                          width: 2
                      ),
                      borderRadius: BorderRadius.circular(24),
                      color: _isOperating?Colors.green[900]:Colors.green[900]?.withOpacity(0.4)
                  ),
                  child: Icon(
                    Icons.add,
                    color: _isOperating?Colors.white:Colors.white.withOpacity(0.4),
                    size: 30,
                  ),
                ),
              ),
            ),

            const SizedBox(width: Constants.defaultPadding),

            Expanded(
              child: GestureDetector(
                onTap: _isOperating?removePassenger:(){},
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: _isOperating?Colors.white:Colors.white.withOpacity(0.4),
                          width: 2
                      ),
                      borderRadius: BorderRadius.circular(24),
                      color: _isOperating?Colors.red[900]:Colors.red[900]?.withOpacity(0.4)
                  ),
                  child: Icon(
                    Icons.remove,
                    color: _isOperating?Colors.white:Colors.white.withOpacity(0.4),
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: Constants.defaultPadding),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      borderRadius: BorderRadius.circular(24)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Plate Number: ${widget.jeep.id}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text("Route: ${routes[widget.jeep.routeId]}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          const Icon(Icons.circle, color: Colors.yellow, size:13)
                        ],
                      ),
                      const Text("Fare: PHP 10.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Constants.defaultPadding),
              Column(
                children: [
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Constants.secondaryColor,
                            borderRadius: BorderRadius.circular(24)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Operate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Switch(
                              value: _isOperating,
                              onChanged: (value) {
                                setState(() {
                                   _isOperating = !_isOperating;
                                });
                              },

                            ),
                          ],
                        )
                    ),
                  ),
                  const SizedBox(height: Constants.defaultPadding),
                  Expanded(
                    child: GestureDetector(
                      onTap: sendLocation,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: _isOperating?Colors.red[900]:Colors.red[900]?.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24)
                        ),
                        child: Center(child: Text("SOS!", style: TextStyle(color: _isOperating?Colors.white:Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 30))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
