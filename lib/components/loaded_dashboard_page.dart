import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../models/jeep_model.dart';
import '../models/routes.dart';
import '../services/location_service.dart';
import '../style/constants.dart';

class LoadedDashboardPage extends StatefulWidget {
  final User user;
  final Jeep jeep;
  const LoadedDashboardPage({super.key, required this.user, required this.jeep});

  @override
  State<LoadedDashboardPage> createState() => _LoadedDashboardPageState();
}

class _LoadedDashboardPageState extends State<LoadedDashboardPage> {
  late String _id;
  late int _routeId;
  late int _passengerCount;
  late int _maxCapacity;
  late GeoPoint _location;
  late double _bearing;
  late bool _isOperating;
  late Timer _timer;
  final updateInterval = 3;

  // for location
  late LocationData _locationData;

  void addPassenger(){
    if(_passengerCount < _maxCapacity) {
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

  void updateFirestore(String deviceId) async {
    _getLocation();
    CollectionReference jeepsCollection = FirebaseFirestore.instance.collection('jeeps_realtime');
    // Query for the document with the specified device_id
    QuerySnapshot querySnapshot = await jeepsCollection.where('device_id', isEqualTo: deviceId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update the attributes of the document
      DocumentSnapshot document = querySnapshot.docs.first;
      if (_isOperating) {
        if (_locationData.heading != 0) {
          jeepsCollection.doc(document.id).update({
            'passenger_count': _passengerCount,
            'slots_remaining': _maxCapacity-_passengerCount,
            'timestamp':  FieldValue.serverTimestamp(),
            'is_active': _isOperating,
            'location': GeoPoint(_locationData.latitude!, _locationData.longitude!),
            'bearing': _locationData.heading
          });
        } else {
          jeepsCollection.doc(document.id).update({
            'passenger_count': _passengerCount,
            'slots_remaining': _maxCapacity-_passengerCount,
            'timestamp':  FieldValue.serverTimestamp(),
            'is_active': _isOperating,
            'location': GeoPoint(_locationData.latitude!, _locationData.longitude!)
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

  Future<void> _getLocation() async {
    try {
      _locationData = await LocationService().getLocation();
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }


  @override
  void initState() {
    _id = widget.jeep.id;
    _routeId = widget.jeep.routeId;
    _passengerCount = widget.jeep.passengerCount;
    _maxCapacity = widget.jeep.maxCapacity;
    _location = widget.jeep.location;
    _bearing = widget.jeep.bearing;
    _isOperating = widget.jeep.isOperating;

    super.initState();
    _getLocation();
    _timer = Timer.periodic(Duration(seconds: updateInterval), (Timer t) => updateFirestore(_id));
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
            "Logged in as ${widget.user.email}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14
            )
        ),

        const SizedBox(height: Constants.defaultPadding*4),

        Text(
            "$_passengerCount/$_maxCapacity",
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
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      borderRadius: BorderRadius.circular(24)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Plate Number: $_id", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text("Route: ${routes[_routeId]}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          Icon(Icons.circle, color: Colors.yellow, size:13)
                        ],
                      ),
                      Text("Fare: PHP 10.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Constants.defaultPadding),
              Column(
                children: [
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10),
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
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.red[900]?.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24)
                      ),
                      child: Center(child: Text("SOS!", style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 30))),
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
