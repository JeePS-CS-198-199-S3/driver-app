import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class DriverEmergency {
  final GeoPoint location;
  final Timestamp timestamp;
  final String jeepId;
  final String driverName;
  final int routeId;
  final int type;

  DriverEmergency({required this.location, required this.timestamp, required this.jeepId, required this.driverName, required this.routeId, required this.type});

  factory DriverEmergency.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    GeoPoint location = data['location'];
    Timestamp timestamp = data['timestamp'];
    String jeepId = data['jeep_id'];
    String driverName = data['driver_name'];
    int routeId = data['route_id'];
    int type = data['type'];

    return DriverEmergency(
      location: location,
      timestamp: timestamp,
      jeepId: jeepId,
      driverName: driverName,
      routeId: routeId,
      type: type
    );
  }
}

class DriverEmergencyCircle {
  final DriverEmergency driverEmergency;
  final Circle driverEmergencyCircle;

  DriverEmergencyCircle({required this.driverEmergency, required this.driverEmergencyCircle});
}