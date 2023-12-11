import 'package:flutter/material.dart';
import 'package:shimmer_effect/shimmer_effect.dart';

import '../style/constants.dart';

class Shimmer extends StatelessWidget {
  final double? width;
  final double? height;
  Shimmer({
    super.key,
    required this.width,
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
        baseColor: Constants.secondaryColor,
        highlightColor: Constants.tertiaryColor,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white
          ),
          width: width,
          height: height,
        )
    );
  }
}
