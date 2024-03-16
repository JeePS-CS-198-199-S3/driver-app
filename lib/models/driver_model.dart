import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String name;
  final String email;
  final bool isVerified;
  late final String jeepDriving;

  Driver(
      {required this.name,
      required this.email,
      required this.isVerified,
      required this.jeepDriving});

  factory Driver.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String name = data['account_name'];
    String email = data['account_email'];
    bool isVerified = data['is_verified'];
    String jeepDriving = data['jeep_driving'];

    return Driver(
      name: name,
      email: email,
      isVerified: isVerified,
      jeepDriving: jeepDriving,
    );
  }
}
