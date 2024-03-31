import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/models/jeep_driver_model.dart';
import 'package:transitrack_driver/models/route_model.dart';

import 'account_model.dart';

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

  static Future<void> updateJeepFirestore(
      String device_id, Map<String, dynamic> dataToUpdate) async {
    try {
      CollectionReference jeepsCollection =
      FirebaseFirestore.instance.collection('jeeps_realtime');
      QuerySnapshot querySnapshot = await jeepsCollection
          .where('device_id', isEqualTo: device_id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await jeepsCollection.doc(docId).update(dataToUpdate);
      } else {
        print('No document found with the given email: $device_id');
      }
    } catch (e) {
      print('Error updating account data: $e');
    }
  }
}

Future<List<JeepDriverData>?> fetchJeeps() async {
  try {
    CollectionReference jeepsCollection = FirebaseFirestore.instance.collection('jeeps_realtime');
    QuerySnapshot jeepsQuerySnapshot = await jeepsCollection.get();

    CollectionReference driverCollection = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot driverQuerySnapshot = await driverCollection.where('account_type', isEqualTo: 1).where('jeep_driving', isNotEqualTo: "").get();


    List<JeepData> jeepsData = jeepsQuerySnapshot.docs.map((e) => JeepData.fromSnapshot(e)).toList();

    List<AccountData> accountsData = driverQuerySnapshot.docs.map((e) => AccountData.fromSnapshot(e)).toList();

    List<JeepDriverData> jeepDriverData = [];

    for (JeepData jeep in jeepsData) {
      AccountData? account;
      if (accountsData.any((account) => account.jeep_driving == jeep.device_id)) {
        account = accountsData.firstWhere((account) => account.jeep_driving == jeep.device_id);
      }

      jeepDriverData.add(
        JeepDriverData(
          jeepData: jeep,
          driverData: account,
        )
      );
    }

    return jeepDriverData;
  } catch (e) {
    print('Error fetching jeep data: $e');
    return null;
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

void updateDriverJeep(String email, Map<String, dynamic> update) async {
  await AccountData.updateAccountFirestore(email, update);
}
