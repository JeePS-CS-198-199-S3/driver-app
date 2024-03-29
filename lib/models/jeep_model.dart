import 'package:cloud_firestore/cloud_firestore.dart';

class JeepData {
  String device_id;
  Timestamp timestamp;
  int passenger_count;
  int max_capacity;
  GeoPoint location;
  int route_id;
  double bearing;

  JeepData({
    required this.device_id,
    required this.timestamp,
    required this.passenger_count,
    required this.max_capacity,
    required this.location,
    required this.route_id,
    required this.bearing,
  });

  factory JeepData.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return JeepData(
      device_id: data['device_id'],
      timestamp: data['timestamp'],
      passenger_count: data['passenger_count'],
      max_capacity: data['max_capacity'],
      location: data['location'],
      route_id: data['route_id'],
      bearing: data['bearing'],
    );
  }
}

Future<JeepData?> fetchJeepData(String deviceId) async {
  try {
    CollectionReference jeepsCollection = FirebaseFirestore.instance.collection('jeeps_realtime');
    QuerySnapshot querySnapshot = await jeepsCollection.where('device_id', isEqualTo: deviceId).get();

    if (querySnapshot.docs.isNotEmpty) {
      return JeepData.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching jeep data: $e');
    return null;
  }
}
