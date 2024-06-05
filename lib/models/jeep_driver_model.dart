import 'package:transitrack_driver/models/jeep_model.dart';
import 'account_model.dart';

// Encapsulate JeepData and AccountData for Entities of operating PUVs

class JeepDriverData {
  JeepData jeepData;
  AccountData? driverData;

  JeepDriverData({
    required this.jeepData,
    required this.driverData,
  });
}