import 'package:flutter/animation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'lat_lng_tween.dart';

void animateCircleMovement(LatLng from, LatLng to, Circle circle, MapboxMapController mapController, TickerProvider tick) {
  final animationController = AnimationController(
    vsync: tick,
    duration: const Duration(milliseconds: 500),
  );
  final animation = LatLngTween(begin: from, end: to).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOut,
  ));

  animation.addListener(() {
    mapController.updateCircle(
        circle, CircleOptions(geometry: animation.value));
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      animationController.dispose();
    }
  });

  animationController.forward();
}