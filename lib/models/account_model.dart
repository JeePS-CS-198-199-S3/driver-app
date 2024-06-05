import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model for Accounts


class AccountData {
  String account_email; // email
  String account_name; // username
  int account_type; // 0 for commuters, 1 for drivers, and 2 for route managers
  bool is_verified; // Only used for Driver and Route Manager Accounts.
  int route_id;
  String?
  jeep_driving; // Used for Driver Accounts. If this is empty (""), it means the driver account is currently not operating.
  bool
  show_discounted; // Used to set if we show the discounted or regular fare when there is an account logged in.

  AccountData(
      {required this.account_email,
        required this.account_name,
        required this.account_type,
        required this.is_verified,
        required this.route_id,
        this.jeep_driving,
        required this.show_discounted
      });

  factory AccountData.fromSnapshot(DocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String account_email = data['account_email'];
    String account_name = data['account_name'];
    int account_type = data['account_type'];
    bool is_verified = data['is_verified'] as bool;
    int route_id = data['route_id'];
    String? jeep_driving = data['jeep_driving'] ?? null;
    bool show_discounted = data['show_discounted'] ?? false;

    return AccountData(
        account_email: account_email,
        account_name: account_name,
        account_type: account_type,
        is_verified: is_verified,
        route_id: route_id,
        show_discounted: show_discounted,
        jeep_driving: jeep_driving);
  }

  static Future<AccountData?> getAccountByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('account_email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AccountData.fromSnapshot(querySnapshot.docs.first);
      } else {
        return null; // No document found with the given email
      }
    } catch (e) {
      print('Error fetching account data: $e');
      return null;
    }
  }

  static Future<AccountData?> getDriverAccountByJeep(String jeep_id) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('account_type', isEqualTo: 1)
          .where('jeep_driving', isEqualTo: jeep_id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AccountData.fromSnapshot(querySnapshot.docs.first);
      } else {
        return null; // No document found with the given email
      }
    } catch (e) {
      print('Error fetching account data: $e');
      return null;
    }
  }

  static Future<void> updateAccountFirestore(
      String email, Map<String, dynamic> dataToUpdate) async {
    try {
      CollectionReference accountsCollection =
      FirebaseFirestore.instance.collection('accounts');
      QuerySnapshot querySnapshot = await accountsCollection
          .where('account_email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await accountsCollection.doc(docId).update(dataToUpdate);
      } else {
        print('No document found with the given email: $email');
      }
    } catch (e) {
      print('Error updating account data: $e');
    }
  }

  static Future<void> updateEmailAndPassword(
      String newEmail, String newPassword) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update email
        await user.updateEmail(newEmail);

        // Update password
        if (newPassword != "") {
          await user.updatePassword(newPassword);
        }

        print('Email and password updated successfully.');
      } else {
        // No user signed in
        print('No user signed in.');
      }
    } catch (e) {
      print('Error updating email and password: $e');
    }
  }

  static Map<String, int> accountTypeMap = {
    'Commuter': 0,
    'Driver': 1,
    'Route Manager': 2,
  };

  static List<String> accountType = ['Commuter', 'Driver', 'Route Manager'];
}
