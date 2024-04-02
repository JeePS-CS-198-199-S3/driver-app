import 'dart:ui';

import 'package:flutter/animation.dart';

class RippleTween extends Tween<double> {
  RippleTween({required double begin, required double end})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) => lerpDouble(begin!, end!, t)!;
}
