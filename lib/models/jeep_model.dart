import 'package:cloud_firestore/cloud_firestore.dart';

class Jeep {
  final String id;            // plate number
  final int routeId;       // 0 for ikot
  final int passengerCount;
  final int maxCapacity;
  final double speed;
  final GeoPoint location;
  final Timestamp timestamp;
  final double bearing;
  final bool isOperating;

  Jeep({
    required this.id,
    required this.routeId,
    required this.passengerCount,
    required this.maxCapacity,
    required this.speed,
    required this.location,
    required this.timestamp,
    required this.bearing,
    required this.isOperating
  });

  factory Jeep.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String id = data['device_id'];
    int routeId = data['route_id'];
    int passengerCount = data['passenger_count'];
    int maxCapacity = 16;
    double speed = data['speed'] as double;
    GeoPoint location = data['location'];
    Timestamp timestamp  = data['timestamp'];
    double bearing = data['bearing'] as double;
    bool isOperating = data['is_active'];

    return Jeep(
      id: id,
      routeId: routeId,
      passengerCount: passengerCount,
      maxCapacity: maxCapacity,
      speed: speed,
      location: location,
      timestamp: timestamp,
      bearing: bearing,
      isOperating: isOperating
    );
  }
}