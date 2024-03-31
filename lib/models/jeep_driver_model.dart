import 'package:transitrack_driver/models/jeep_model.dart';
import 'package:transitrack_driver/models/route_model.dart';

import 'account_model.dart';

class JeepDriverData {
  JeepData jeepData;
  AccountData? driverData;

  JeepDriverData({
    required this.jeepData,
    required this.driverData,
  });
}