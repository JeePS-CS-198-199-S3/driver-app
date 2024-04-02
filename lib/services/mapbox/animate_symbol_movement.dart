import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_driver/models/route_model.dart';

import '../../components/map_widget.dart';
import '../int_to_hex.dart';
import 'lat_lng_tween.dart';

void animateSymbolMovement(LatLng from, LatLng to, Symbol symbol, MapboxMapController mapController, TickerProvider tick, RouteData? routeData, double heading) {
  final animationController = AnimationController(
    vsync: tick,
    duration: const Duration(milliseconds: 500),
  );
  final animation = LatLngTween(begin: from, end: to).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOut,
  ));

  mapController.updateSymbol(
    symbol, SymbolOptions(
      textRotate: heading + 90,
    iconRotate: heading,
    textColor: routeData != null
      ? intToHexColor(routeData.routeColor)
      : intToHexColor(Colors.grey.value)));

  animation.addListener(() {
    mapController.updateSymbol(
        symbol, SymbolOptions(geometry: animation.value));
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      animationController.dispose();
    }
  });

  animationController.forward();
}