import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/driver_model.dart';
import '../models/jeep_model.dart';
import '../models/routes.dart';
import '../style/constants.dart';

class JeepTile extends StatelessWidget {
  final String driver;
  final Jeep jeep;
  void Function()? onPressed;
  JeepTile({super.key, required this.driver, required this.jeep, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.defaultPadding),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        color: Constants.secondaryColor,
        borderRadius: BorderRadius.circular(12)
      ),
      child: ListTile(
        title: Text(jeep.id, style: const TextStyle(color: Colors.white),),
        subtitle: Text("$driver, Capacity: ${jeep.maxCapacity}", style: TextStyle(color: Colors.grey[400])),
        leading: Image.asset(
            'lib/images/${routes[jeep.routeId]}_front.png',
            height: 40
        ),
        onTap: onPressed,
      ),
    );
  }
}
