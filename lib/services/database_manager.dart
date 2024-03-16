import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';

List<String> jeepFrontImg = [
  'lib/images/ikot_front.png',
  'lib/images/toki_front.png',
  'lib/images/katip_front.png',
  'lib/images/philcoa_front.png',
  'lib/images/sm_front.png',
];

Future<List<Jeep>> getJeepsFromFirestore(int route) async {
  if (route != -1) {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('jeeps_realtime')
        .where('route_id', isEqualTo: route)
        .get();
    return snapshot.docs.map((doc) => Jeep.fromSnapshot(doc)).toList();
  } else {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('jeeps_realtime').get();
    return snapshot.docs.map((doc) => Jeep.fromSnapshot(doc)).toList();
  }
}

Future<List<Driver>> getDrivers() async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('accounts') // Replace with your collection name
            .get();

    // Convert the QuerySnapshot into a List<Driver>
    List<Driver> drivers =
        querySnapshot.docs.map((doc) => Driver.fromSnapshot(doc)).toList();

    return drivers;
  } catch (e) {
    // Handle errors here
    print("Error fetching drivers: $e");
    return [];
  }
}

Future<Driver?> getDriverByEmail(String email) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('accounts') // Replace with your collection name
            .where('account_email', isEqualTo: email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming that there is only one document with the given email
      return Driver.fromSnapshot(querySnapshot.docs.first);
    } else {
      // No document found with the given email
      return null;
    }
  } catch (e) {
    // Handle errors here
    print("Error fetching driver by email: $e");
    return null;
  }
}

Future<Jeep?> getJeepById(String jeepId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('jeeps_realtime') // Replace with your collection name
            .where('device_id', isEqualTo: jeepId)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming that there is only one document with the given jeepId
      return Jeep.fromSnapshot(querySnapshot.docs.first);
    } else {
      // No document found with the given jeepId
      return null;
    }
  } catch (e) {
    // Handle errors here
    print("Error fetching Jeep by ID: $e");
    return null;
  }
}

Future<Routes?> getRouteById(int routeId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('routes') // Replace with your collection name
            .where('route_id', isEqualTo: routeId)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming that there is only one document with the given jeepId
      return Routes.fromSnapshot(querySnapshot.docs.first);
    } else {
      // No document found with the given jeepId
      return null;
    }
  } catch (e) {
    // Handle errors here
    print("Error fetching Route by ID: $e");
    return null;
  }
}

Future<void> updateJeepDriving(String email, String newJeepDriving) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('accounts')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(documentId)
          .update({'jeepDriving': newJeepDriving});

      print('Jeep driving attribute updated successfully');
    } else {
      print('No document found with email: $email');
    }
  } catch (e) {
    print('Error updating jeep driving attribute: $e');
  }
}
