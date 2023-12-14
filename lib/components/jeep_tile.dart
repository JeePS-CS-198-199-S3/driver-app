import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../services/database_manager.dart';
import '../style/constants.dart';

class JeepTile extends StatelessWidget {
  final Jeep jeep;
  void Function()? onPressed;
  JeepTile({super.key, required this.jeep, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.defaultPadding),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        color: Constants.secondaryColor,
        borderRadius: BorderRadius.circular(12)
      ),
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('drivers')
              .where('jeepDriving', isEqualTo: jeep.id)
              .get()
              .then((querySnapshot) => querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 70);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null) {
              return ListTile(
                title: Text(jeep.id, style: const TextStyle(color: Colors.white)),
                subtitle: Text('Vacant, Capacity: ${jeep.maxCapacity}', style: TextStyle(color: Colors.grey[400])),
                leading: Image.asset(
                    jeepFrontImg[jeep.routeId],
                    height: 40
                ),
                onTap: onPressed,
              );
            } else {
              Driver driver = Driver.fromSnapshot(snapshot.data!);
              return ListTile(
                title: Text(jeep.id, style: const TextStyle(color: Colors.white),),
                subtitle: Text("${driver.name}, Capacity: ${jeep.maxCapacity}", style: TextStyle(color: Colors.grey[400])),
                leading: Image.asset(
                    'lib/images/ikot_front.png',
                    height: 40
                ),
                onTap: onPressed,
              );
            }
          }
      ),
    );
  }
}
