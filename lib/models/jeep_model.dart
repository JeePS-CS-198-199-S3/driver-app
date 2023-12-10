import 'package:latlng/latlng.dart';

class Jeep {
  final String id;            // plate number
  final String routeId;       // 0 for ikot
  final String driverId;
  final int passengerCount;
  final int maxCapacity;
  final num speed;
  final LatLng location;

  Jeep({
    required this.id,
    required this.routeId,
    required this.driverId,
    required this.passengerCount,
    required this.maxCapacity,
    required this.speed,
    required this.location});
}