import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  void createUserDocument(User? user) async {
    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('accounts').doc(user.uid);

      // Check if the document already exists
      if (!(await userDocRef.get()).exists) {
        // If the document doesn't exist, create it
        await userDocRef.set({
          'account_name': user.displayName,
          'account_email': user.email,
          'account_type': 1,
          'is_operating': false,
          'jeep_driving': "",
          'is_verified': false,
          'route_id': -1,
        });
      }
    }
  }
}
