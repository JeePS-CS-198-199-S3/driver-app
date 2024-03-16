import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:location/location.dart';

import '../models/driver_model.dart';
import '../models/route_model.dart';
import '../models/jeep_model.dart';
import '../models/routes.dart';
import '../style/constants.dart';
import 'button.dart';

class LoadedDashboardPage extends StatefulWidget {
  final Driver driver;
  final Jeep jeep;
  final Routes route;
  const LoadedDashboardPage(
      {super.key,
      required this.driver,
      required this.jeep,
      required this.route});

  @override
  State<LoadedDashboardPage> createState() => _LoadedDashboardPageState();
}

class TopClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, 110); // Clip to top 120 pixels
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
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
  late StreamSubscription<LocationData> locationSubscription;

  void addPassenger() {
    if (_passengerCount < widget.jeep.maxCapacity) {
      setState(() {
        _passengerCount++;
      });
    }
  }

  void removePassenger() {
    if (_passengerCount > 0) {
      setState(() {
        _passengerCount--;
      });
    }
  }

  void emptyPassenger() {
    setState(() {
      _passengerCount = 0;
    });
  }

  void fullPassenger() {
    setState(() {
      _passengerCount = widget.jeep.maxCapacity;
    });
  }

  void sendLocation(int type) {
    CollectionReference driverEmergencyCollection =
        FirebaseFirestore.instance.collection('driver_emergency');
    driverEmergencyCollection.add({
      'location': GeoPoint(_locationData!.latitude!, _locationData!.longitude!),
      'timestamp': FieldValue.serverTimestamp(),
      'jeep_id': widget.jeep.id,
      'driver_name': widget.driver.name,
      'route_id': widget.jeep.routeId,
      'type': type
    });
  }

  void updateFirestoreJeep(String deviceId) async {
    // _getLocation();
    CollectionReference jeepsCollection =
        FirebaseFirestore.instance.collection('jeeps_realtime');
    // Query for the document with the specified device_id
    QuerySnapshot querySnapshot =
        await jeepsCollection.where('device_id', isEqualTo: deviceId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update the attributes of the document
      DocumentSnapshot document = querySnapshot.docs.first;
      if (_isOperating) {
        if (_locationData?.heading != 0) {
          jeepsCollection.doc(document.id).update({
            'passenger_count': _passengerCount,
            'slots_remaining': widget.jeep.maxCapacity - _passengerCount,
            'timestamp': FieldValue.serverTimestamp(),
            'is_active': _isOperating,
            'location':
                GeoPoint(_locationData!.latitude!, _locationData!.longitude!),
            'bearing': _locationData!.heading
          });
        } else {
          jeepsCollection.doc(document.id).update({
            'passenger_count': _passengerCount,
            'slots_remaining': widget.jeep.maxCapacity - _passengerCount,
            'timestamp': FieldValue.serverTimestamp(),
            'is_active': _isOperating,
            'location':
                GeoPoint(_locationData!.latitude!, _locationData!.longitude!)
          });
        }
      } else {
        jeepsCollection.doc(document.id).update({'is_active': _isOperating});
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
    locationSubscription =
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
    _timer = Timer.periodic(Duration(seconds: updateInterval),
        (Timer t) => updateFirestoreJeep(widget.jeep.id));
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    locationSubscription.cancel();
    super.dispose();
  }

  // Initial Selected Value
  String passengerCounterWay = 'Active';

  // List of items in our dropdown menu
  var items = [
    'Active',
    'Semi-active',
    'Passive',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Constants.bgColor,
        child: Column(
          children: [
            /*Text("Logged in as ${widget.driver.email}",
                  style: const TextStyle(
                      color: Color.fromARGB(155, 255, 255, 255), fontSize: 14)),*/
            //Passenger Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: Constants.defaultPadding),
                const Text("Passenger Counter:",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    // Initial Value
                    value: passengerCounterWay,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    dropdownColor: Constants.tertiaryColor,
                    elevation: 2,
                    isDense: false,
                    alignment: Alignment.center,

                    itemHeight: 50,
                    focusColor: Constants.secondaryColor,
                    onChanged: (String? newValue) {
                      setState(() {
                        passengerCounterWay = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: Constants.defaultPadding),
              ],
            ),
            //passenger counter box
            Container(
                padding: const EdgeInsets.all(Constants.defaultPadding),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Color.fromARGB(102, 255, 255, 255), width: 2),
                    borderRadius:
                        BorderRadius.circular(Constants.defaultPadding)),
                child: Stack(
                  children: [
                    //pie chart
                    ClipRect(
                      clipper: TopClipper(),
                      child: SizedBox(
                        height: 230,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 80,
                                startDegreeOffset: -180,
                                sections: [
                                  PieChartSectionData(
                                    color: Color(widget.route.routeColor),
                                    value: (_passengerCount).toDouble(),
                                    showTitle: false,
                                    radius: 30,
                                  ),
                                  PieChartSectionData(
                                    color: Color(widget.route.routeColor)
                                        .withOpacity(0.1),
                                    value: (widget.jeep.maxCapacity -
                                            _passengerCount)
                                        .toDouble(),
                                    showTitle: false,
                                    radius: 30,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.transparent,
                                    value: (widget.jeep.maxCapacity).toDouble(),
                                    showTitle: false,
                                    radius: 30,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    height: Constants.defaultPadding * 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "$_passengerCount/${widget.jeep.maxCapacity}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    //full and empty button for active
                    Column(
                      children: [
                        Row(
                          children: [
                            //empty button
                            GestureDetector(
                              onTap: _isOperating ? emptyPassenger : () {},
                              child: Container(
                                width: 70,
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _isOperating
                                            ? Colors.white.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.1),
                                        width: 4),
                                    borderRadius: BorderRadius.circular(13),
                                    color: _isOperating
                                        ? Colors.red[900]
                                        : Colors.red[900]?.withOpacity(0.4)),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Empty",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: Constants.defaultPadding),
                            const Spacer(),
                            const Spacer(),
                            //full button
                            GestureDetector(
                              onTap: _isOperating ? fullPassenger : () {},
                              child: Container(
                                width: 70,
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _isOperating
                                            ? Colors.white.withOpacity(.2)
                                            : Colors.white.withOpacity(0.1),
                                        width: 4),
                                    borderRadius: BorderRadius.circular(13),
                                    color: _isOperating
                                        ? Colors.green[900]
                                        : Colors.green[900]?.withOpacity(0.4)),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Full",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    //plus and minus button for active
                    Column(
                      children: [
                        const SizedBox(height: Constants.defaultPadding * 9),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _isOperating ? removePassenger : () {},
                              child: Container(
                                width: 140,
                                height: 80,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _isOperating
                                            ? Colors.white.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.1),
                                        width: 4),
                                    borderRadius: BorderRadius.circular(13),
                                    color: _isOperating
                                        ? Colors.red[900]
                                        : Colors.red[900]?.withOpacity(0.4)),
                                child: Icon(
                                  Icons.remove,
                                  color: _isOperating
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  size: 50,
                                ),
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: _isOperating ? addPassenger : () {},
                              child: Container(
                                width: 140,
                                height: 80,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _isOperating
                                            ? Colors.white.withOpacity(.2)
                                            : Colors.white.withOpacity(0.1),
                                        width: 4),
                                    borderRadius: BorderRadius.circular(13),
                                    color: _isOperating
                                        ? Colors.green[900]
                                        : Colors.green[900]?.withOpacity(0.4)),
                                child: Icon(
                                  Icons.add,
                                  color: _isOperating
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  size: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: Constants.defaultPadding * 1),
            const Divider(
              height: 1,
              color: Color.fromARGB(102, 158, 158, 158),
            ),
            const SizedBox(height: Constants.defaultPadding * 1),
            //operate and SOS buttons
            Row(
              children: [
                //operate button
                Container(
                    height: 110,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Constants.secondaryColor,
                        border: Border.all(
                            color: const Color.fromARGB(102, 255, 255, 255),
                            width: 2),
                        borderRadius: BorderRadius.circular(13)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Operate",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Switch(
                          value: _isOperating,
                          onChanged: (value) {
                            setState(() {
                              _isOperating = !_isOperating;
                            });
                          },
                        ),
                      ],
                    )),
                const Spacer(),
                Container(
                  height: 110,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      border: Border.all(
                          color: const Color.fromARGB(102, 255, 255, 255),
                          width: 2),
                      borderRadius: BorderRadius.circular(13)),
                  child: Row(
                    children: [
                      //SOS text
                      const Column(
                        children: [
                          Text("S",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text("O",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text("S",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: Constants.defaultPadding * 1),
                      //crime button
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.red[900],
                                borderRadius: BorderRadius.circular(7)),
                          ),
                          const Spacer(),
                          const Text("Crime",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ],
                      ),
                      const SizedBox(width: Constants.defaultPadding * 1),
                      //mech error button
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.red[900],
                                borderRadius: BorderRadius.circular(7)),
                          ),
                          const Spacer(),
                          const Text("Mech Error",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ],
                      ),
                      const SizedBox(width: Constants.defaultPadding * 1),
                      //accident button
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.red[900],
                                borderRadius: BorderRadius.circular(7)),
                          ),
                          const Spacer(),
                          const Text("Accident",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.defaultPadding * 1),
            const Divider(
              height: 1,
              color: Color.fromARGB(102, 158, 158, 158),
            ),
            const SizedBox(height: Constants.defaultPadding * 1),
            //info box
            Container(
                padding: const EdgeInsets.all(Constants.defaultPadding),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Color.fromARGB(102, 255, 255, 255), width: 2),
                    borderRadius:
                        BorderRadius.circular(Constants.defaultPadding)),
                child: Column(
                  children: [
                    //plate number
                    Row(
                      children: [
                        Text("4.5",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: Constants.defaultPadding * 1),
                        Text("Plt Num",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Spacer(),
                        Text("${widget.jeep.id}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: Constants.defaultPadding * 0.75),
                    const Divider(
                      height: 1,
                      color: Color.fromARGB(102, 158, 158, 158),
                    ),
                    const SizedBox(height: Constants.defaultPadding * 0.75),
                    //driver name
                    Row(
                      children: [
                        Text("4.0",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: Constants.defaultPadding * 1),
                        Text("Driver",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Spacer(),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text("${widget.driver.name}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Constants.defaultPadding * 0.75),
                    const Divider(
                      height: 1,
                      color: Color.fromARGB(102, 158, 158, 158),
                    ),
                    const SizedBox(height: Constants.defaultPadding * 0.75),
                    //route name
                    Row(
                      children: [
                        Icon(Icons.circle,
                            color: Color(widget.route.routeColor), size: 18),
                        const SizedBox(width: Constants.defaultPadding * 1),
                        const Text("Route",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Spacer(),
                        Text("${routes[widget.jeep.routeId]}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: Constants.defaultPadding * 0.75),
                    const Divider(
                      height: 1,
                      color: Color.fromARGB(102, 158, 158, 158),
                    ),
                    const SizedBox(height: Constants.defaultPadding * 0.75),
                    //fare prices
                    Row(
                      children: [
                        Text("Regular: ${widget.route.routeFare}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(width: Constants.defaultPadding * 1),
                        Spacer(),
                        Text("Discounted: ${widget.route.routeFareDiscounted}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ],
                )),
            /*Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Plate Number: ${widget.jeep.id}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text("Route: ${routes[widget.jeep.routeId]}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          Icon(Icons.circle,
                              color: Color(widget.route.routeColor), size: 13)
                        ],
                      ),
                      Text(
                          "Fare: ${widget.route.routeFare}/${widget.route.routeFareDiscounted}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: Constants.defaultPadding),
                Column(
                  children: [
                    const SizedBox(height: Constants.defaultPadding),
                    GestureDetector(
                      onTap: () {
                        int choice = 0;
                        bool selected = false;
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.noHeader,
                            showCloseIcon: true,
                            body: Padding(
                              padding: const EdgeInsets.all(
                                  Constants.defaultPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Button(
                                      onTap: () {
                                        choice = 0;
                                        selected = true;
                                      },
                                      text: "Accident"),
                                  Button(
                                      onTap: () {
                                        choice = 1;
                                        selected = true;
                                      },
                                      text: "Crime"),
                                  Button(
                                      onTap: () {
                                        choice = 2;
                                        selected = true;
                                      },
                                      text: "Mechanical\nProblem")
                                ],
                              ),
                            ),
                            btnOkText: 'Send Distress Signal',
                            btnOkOnPress: () {
                              if (selected) {
                                sendLocation(choice);
                              }
                            }).show();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: _isOperating
                                ? Colors.red[900]
                                : Colors.red[900]?.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24)),
                        child: Center(
                            child: Text("SOS!",
                                style: TextStyle(
                                    color: _isOperating
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30))),
                      ),
                    ),
                  ],
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}
