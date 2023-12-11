import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/components/shimmer.dart';

import '../style/constants.dart';

class JeepneyPageLoader extends StatelessWidget {
  const JeepneyPageLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(width: 150, height: 25),
          const SizedBox(height: Constants.defaultPadding),
          Shimmer(width: double.maxFinite, height: 120),
          const SizedBox(height: Constants.defaultPadding),
          Shimmer(width: double.maxFinite, height: 120),
          const SizedBox(height: Constants.defaultPadding),
          Shimmer(width: double.maxFinite, height: 120),
        ],
      ),
    );
  }
}