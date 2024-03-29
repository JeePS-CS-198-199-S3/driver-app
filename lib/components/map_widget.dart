import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../services/device_location/request_permission.dart';
import '../services/mapbox.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
    lerpDouble(begin!.latitude, end!.latitude, t)!,
    lerpDouble(begin!.longitude, end!.longitude, t)!,
  );
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late MapboxMapController _mapController;

  // Device Location
  Location location = Location();
  LatLng? deviceLocation;
  Circle? deviceCircle;

  @override
  void initState() {
    super.initState();

    location.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  void _listenDeviceLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      _updateDeviceCircle(LatLng(currentLocation.latitude!, currentLocation.longitude!));
    });
  }

  void startListening() async
  {
    // TODO IMPLEMENT ERROR HANDLING
    await requestLocationPermission();

    _listenDeviceLocation();
  }

  void _updateDeviceCircle(LatLng latLng) {
    setState(() {
      deviceLocation = latLng;
    });
    if (deviceCircle != null) {
      _animateCircleMovement(
          deviceCircle!.options.geometry as LatLng, latLng, deviceCircle!);
    } else {
      _mapController
          .addCircle(CircleOptions(
          geometry: latLng,
          circleRadius: 3,
          circleColor: '#FFFFFF',
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF'))
          .then((circle) {
        deviceCircle = circle;
      });
    }
    _mapController
        .animateCamera(CameraUpdate.newLatLng(deviceLocation!));
  }

  void _animateCircleMovement(LatLng from, LatLng to, Circle circle) {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final animation = LatLngTween(begin: from, end: to).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      _mapController.updateCircle(
          circle, CircleOptions(geometry: animation.value));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  @override
  void dispose() {
    _mapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: accessToken,
      initialCameraPosition: const CameraPosition(
          target: initialCameraPosition,
          zoom: zoom
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onStyleLoadedCallback: () {
        startListening();
      },
      styleString: mapStyle,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
    );
  }
}
