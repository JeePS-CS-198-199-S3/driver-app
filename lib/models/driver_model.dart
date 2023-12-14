import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String name;
  final String email;
  final bool isVerified;
  final String jeepDriving;

  Driver({required this.name, required this.email, required this.isVerified, required this.jeepDriving});

  factory Driver.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String name = data['name'];
    String email = data['email'];
    bool isVerified = data['isVerified'];
    String jeepDriving = data['jeepDriving'];

    return Driver(
      name: name,
      email: email,
      isVerified: isVerified,
      jeepDriving: jeepDriving,
    );
  }
}