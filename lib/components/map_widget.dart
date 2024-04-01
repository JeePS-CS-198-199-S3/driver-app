import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../services/device_location/request_permission.dart';
import '../services/int_to_hex.dart';
import '../services/mapbox.dart';
import '../services/mapbox/add_image_assets.dart';
import '../services/mapbox/animate_ripple.dart';

class MapWidget extends StatefulWidget {
  final int? jeepColor;
  final ValueChanged<LocationData> jeepLocation;
  MapWidget({Key? key, this.jeepColor, required this.jeepLocation}) : super(key: key,);

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
  int? _jeepColor;

  late MapboxMapController _mapController;

  // Device Location
  StreamSubscription<LocationData>? locationListener;
  Location location = Location();
  LatLng? deviceLocation;
  double? heading;
  Circle? deviceCircle;
  Symbol? deviceSymbol;

  @override
  void initState() {
    super.initState();

    location.enableBackgroundMode();

    location.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    setState(() {
      _jeepColor = widget.jeepColor;
    });


  }

  @override
  void dispose() {
    _mapController.dispose();
    locationListener?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_jeepColor != widget.jeepColor) {
      setState(() {
        _jeepColor = widget.jeepColor;
      });

      if (deviceLocation != null) {
        if (_jeepColor != null) {
          if (deviceCircle != null) {
            _mapController.removeCircle(deviceCircle!);
            deviceCircle = null;
          }
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

  void _listenDeviceLocation() {
    locationListener = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        deviceLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        heading = currentLocation.heading!;
      });

      if (_jeepColor != null) {
        _updateDeviceJeep();
        widget.jeepLocation(currentLocation);
      } else {
        _updateDeviceCircle();
      }
    });
  }

  Future<void> rippleReport() async {
    for (int i = 0; i < 3; i++) {
      animateRipple(deviceLocation!, _mapController, this);

      await Future.delayed(
          const Duration(milliseconds: 2000));
    }

  }


  void startListening() async
  {
    // TODO IMPLEMENT ERROR HANDLING
    await requestLocationPermission();

    _listenDeviceLocation();
  }

  void _updateDeviceCircle() {
    if (deviceCircle != null) {
      _animateCircleMovement(
          deviceCircle!.options.geometry as LatLng, deviceLocation!, deviceCircle!);
    } else {
      _mapController
          .addCircle(CircleOptions(
          geometry: deviceLocation,
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

  void _updateDeviceJeep() {
    if (deviceSymbol != null) {
      _animateSymbolMovement(
          deviceSymbol!.options.geometry as LatLng, deviceLocation!, deviceSymbol!);
    } else {
      _mapController
          .addSymbol(SymbolOptions(
          geometry: deviceLocation!,
          iconImage: "jeepTop",
          textField: "▬▬",
          textLetterSpacing: -0.35,
          textSize: 30,
          textColor: _jeepColor != null? intToHexColor(_jeepColor!):intToHexColor(Colors.grey.value),
          textRotate: heading! + 90,
          iconRotate: heading,
          iconSize: 2))
          .then((jeepIcon) {
        deviceSymbol = jeepIcon;
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

  void _animateSymbolMovement(LatLng from, LatLng to, Symbol symbol) {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final animation = LatLngTween(begin: from, end: to).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    _mapController.updateSymbol(
        symbol, SymbolOptions(textRotate: heading! + 90, iconRotate: heading));

    animation.addListener(() {
      _mapController.updateSymbol(
          symbol, SymbolOptions(geometry: animation.value));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      }
    });

    animationController.forward();
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
      onStyleLoadedCallback: () async {
        await addImagesFromAsset(_mapController);
        _mapController.setSymbolIconAllowOverlap(true);
        _mapController.setSymbolTextAllowOverlap(true);
        _mapController.setSymbolIconIgnorePlacement(true);
        _mapController.setSymbolTextIgnorePlacement(true);
        startListening();
      },
      styleString: mapStyle,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
    );
  }
}

class RippleTween extends Tween<double> {
  RippleTween({required double begin, required double end})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) => lerpDouble(begin!, end!, t)!;
}

final GlobalKey<_MapWidgetState> mapWidgetKey = GlobalKey<_MapWidgetState>();