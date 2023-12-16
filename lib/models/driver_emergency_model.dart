import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class DriverEmergency {
  final GeoPoint location;
  final Timestamp timestamp;
  final String jeepId;
  final String driverName;
  final int routeId;

  DriverEmergency({required this.location, required this.timestamp, required this.jeepId, required this.driverName, required this.routeId});

  factory DriverEmergency.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    GeoPoint location = data['location'];
    Timestamp timestamp = data['timestamp'];
    String jeepId = data['jeep_id'];
    String driverName = data['driver_name'];
    int routeId = data['route_id'];

    return DriverEmergency(
      location: location,
      timestamp: timestamp,
      jeepId: jeepId,
      driverName: driverName,
      routeId: routeId
    );
  }
}

class DriverEmergencyCircle {
  final DriverEmergency driverEmergency;
  final CircleOptions circleOptions;

  DriverEmergencyCircle({required this.driverEmergency, required this.circleOptions});
}