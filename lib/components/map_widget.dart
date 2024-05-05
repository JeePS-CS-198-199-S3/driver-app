import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../models/account_model.dart';
import '../models/ping_model.dart';
import '../models/report_model.dart';
import '../models/route_model.dart';
import '../services/int_to_hex.dart';
import '../services/mapbox.dart';
import '../services/mapbox/add_image_assets.dart';
import '../services/mapbox/animate_circle_movement.dart';
import '../services/mapbox/animate_ripple.dart';
import '../services/mapbox/animate_symbol_movement.dart';
import '../services/mapbox/minute_old_checker.dart';

class MapWidget extends StatefulWidget {
  final AccountData driverData;
  final RouteData? routeData;
  final ValueChanged<LocationData> jeepLocation;
  MapWidget({Key? key, required this.driverData, required this.routeData, required this.jeepLocation}) : super(key: key,);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  RouteData? _routeData;

  late MapboxMapController _mapController;

  // Ping Fetching
  StreamSubscription? pingListener;
  List<PingData> pings = [];
  late Timer timer;

  // SOS Fetching
  StreamSubscription? SOSListener;
  List<ReportData> SOSList = [];
  bool SOSLayerSetup = false;

  // Device Location
  late StreamSubscription<LocationData> locationListener;
  Location location = Location();
  LocationData? deviceLocation;
  Circle? deviceCircle;
  Symbol? deviceSymbol;

  bool mapLoaded = false;

  @override
  void initState() {
    super.initState();

    location.enableBackgroundMode();

    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 7500
    );

    setState(() {
      _routeData = widget.routeData;
    });
    if (mapLoaded) {
      refreshLineAndPingLayer();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mapLoaded && _routeData != null) {
        setState(() {
          pings = pings.where((element) => minuteOldChecker(element.ping_timestamp.toDate())).toList();
          SOSList = SOSList.where((element) => minuteOldChecker(element.timestamp.toDate())).toList();
        });
        _mapController.setGeoJsonSource("pings", pingListToGeoJSON(pings));
        _mapController.setGeoJsonSource("accidents", reportListToGeoJSON(SOSList.where((element) => element.report_type == 3).toList()));
        _mapController.setGeoJsonSource("crime", reportListToGeoJSON(SOSList.where((element) => element.report_type == 1).toList()));
        _mapController.setGeoJsonSource("mechError", reportListToGeoJSON(SOSList.where((element) => element.report_type == 2).toList()));
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    locationListener.cancel();
    pingListener?.cancel();
    SOSListener?.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_routeData != widget.routeData) {
      setState(() {
        _routeData = widget.routeData;
      });

      refreshLineAndPingLayer();

      if (deviceLocation != null) {
        if (_routeData != null) {
          if (deviceCircle != null) {
            _mapController.removeCircle(deviceCircle!);
            deviceCircle = null;
          }
          widget.jeepLocation(deviceLocation!);
          _updateDeviceJeep();
        } else {
          if (deviceSymbol != null) {
            _mapController.removeSymbol(deviceSymbol!);
            deviceSymbol = null;
          }

          _updateDeviceCircle();
        }
      }
    }
  }

  void listenToReportsFirestore() {
    if (_routeData != null) {
      SOSListener = FirebaseFirestore.instance
          .collection('reports')
          .where('report_sender', isNotEqualTo: widget.driverData.account_email)
          .where('report_route', isEqualTo: _routeData!.routeId)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            SOSList =
                snapshot.docs.map((doc) => ReportData.fromFirestore(doc)).where((element) => minuteOldChecker(element.timestamp.toDate())).toList();
          });
          _mapController.setGeoJsonSource("accidents", reportListToGeoJSON(SOSList.where((element) => element.report_type == 3).toList()));
          _mapController.setGeoJsonSource("crime", reportListToGeoJSON(SOSList.where((element) => element.report_type == 1).toList()));
          _mapController.setGeoJsonSource("mechError", reportListToGeoJSON(SOSList.where((element) => element.report_type == 2).toList()));
        }
      });
    } else {
      SOSListener?.cancel();
      SOSList.clear();
      _mapController.setGeoJsonSource("SOS-accidents", reportListToGeoJSON([]));
    }
  }

  void listenToPingsFirestore() {
    pingListener = FirebaseFirestore.instance
        .collection('pings')
        .where('ping_route', isEqualTo: _routeData!.routeId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          pings =
              snapshot.docs.map((doc) => PingData.fromFirestore(doc)).where((element) => minuteOldChecker(element.ping_timestamp.toDate())).toList();
        });
        _mapController.setGeoJsonSource("pings", pingListToGeoJSON(pings));
      }
    });
  }

  void _listenDeviceLocation() {
    locationListener = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        deviceLocation = currentLocation;
      });

      if (_routeData != null) {
        _updateDeviceJeep();
        widget.jeepLocation(currentLocation);
      } else {
        _updateDeviceCircle();
      }
    });
  }

  Future<void> rippleReport(LatLng deviceLocation) async {
    for (int i = 0; i < 3; i++) {
      animateRipple(deviceLocation, _mapController, this);

      await Future.delayed(
          const Duration(milliseconds: 2000));
    }
  }

  void _updateDeviceCircle() {
    if (deviceCircle != null) {
      animateCircleMovement(
          deviceCircle!.options.geometry as LatLng, LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!), deviceCircle!, _mapController, this);
    } else {
      _mapController
          .addCircle(CircleOptions(
          geometry: LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!),
          circleRadius: 3,
          circleColor: '#FFFFFF',
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF'))
          .then((circle) {
        deviceCircle = circle;
      });
    }
    _mapController
        .animateCamera(CameraUpdate.newLatLng(LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!)));
  }

  void _updateDeviceJeep() {
    if (deviceSymbol != null) {
      animateSymbolMovement(
          deviceSymbol!.options.geometry as LatLng, LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!), deviceSymbol!, _mapController, this, _routeData, deviceLocation!.heading!);
    } else {
      _mapController
          .addSymbol(SymbolOptions(
          geometry: LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!),
          iconImage: "jeepTop",
          textField: "▬▬",
          textLetterSpacing: -0.35,
          textSize: 30,
          textColor: _routeData != null? intToHexColor(_routeData!.routeColor):intToHexColor(Colors.grey.value),
          textRotate: deviceLocation!.heading! + 90,
          iconRotate: deviceLocation!.heading!,
          iconSize: 2))
          .then((jeepIcon) {
        deviceSymbol = jeepIcon;
      });
    }
    _mapController
        .animateCamera(CameraUpdate.newLatLng(LatLng(deviceLocation!.latitude!, deviceLocation!.longitude!)));
  }

  void refreshLineAndPingLayer() {
    if (_routeData != null) {
      _mapController.clearLines();
      _mapController.addLines(
          [LineOptions(
              lineWidth: 4.0,
              lineColor: intToHexColor(_routeData!.routeColor),
              lineOpacity: 0.5,
              geometry: _routeData!.routeCoordinates
          )]
      );
      addGeojsonCluster(_mapController, _routeData!);
      addGeojsonSOS(_mapController);
      listenToPingsFirestore();
      listenToReportsFirestore();
    } else {
      _mapController.clearLines();
      pingListener?.cancel();
      pings.clear();
      _mapController.setGeoJsonSource("pings", pingListToGeoJSON(pings));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: accessToken,
      initialCameraPosition: const CameraPosition(
          target: initialCameraPosition,
          zoom: zoom
      ),
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        setState(() {
          mapLoaded = true;
        });
      },
      onStyleLoadedCallback: () async {

        await addImagesFromAsset(_mapController);
        _mapController.setSymbolIconAllowOverlap(true);
        _mapController.setSymbolTextAllowOverlap(true);
        _mapController.setSymbolIconIgnorePlacement(true);
        _mapController.setSymbolTextIgnorePlacement(true);
        refreshLineAndPingLayer();
        await addGeojsonSOS(_mapController).then((value) => setState(() {
          SOSLayerSetup = true;
        }));
        _listenDeviceLocation();
      },
      styleString: mapStyle,
    );
  }
}

final GlobalKey<_MapWidgetState> mapWidgetKey = GlobalKey<_MapWidgetState>();