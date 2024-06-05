import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/models/jeep_driver_model.dart';

import '../components/square_loader.dart';
import '../style/constants.dart';

// Uploads a new document in Reports collection once called

Future<bool> sendReport(BuildContext context, JeepDriverData jeepDriverData, int reportType) async {
  // show loading circle
  Loader(context);

  bool success = false;

  try {
    // Add a new document with auto-generated ID
    await FirebaseFirestore.instance
        .collection('reports')
        .add({
      'report_sender': jeepDriverData.driverData!.account_email,
      'report_recepient': jeepDriverData.driverData!.account_email,
      'report_jeepney': jeepDriverData.jeepData.device_id,
      'timestamp': FieldValue.serverTimestamp(),
      'report_content': "This is a distress signal of an operating driver. He is unable to type a report message. Immediate response might be necessary.",
      'report_type': reportType,
      'report_location': GeoPoint(jeepDriverData.jeepData.location.latitude, jeepDriverData.jeepData.location.longitude),
      'report_route': jeepDriverData.jeepData.route_id
    })
    .then((value) => Navigator.pop(context));

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: "SOS Sent!",
      desc: "Your report has been broadcasted to your route manager and all operating drivers in your route.",
      padding: const EdgeInsets.only(bottom: Constants.defaultPadding, left: Constants.defaultPadding, right: Constants.defaultPadding)
    ).show();
    success = true;
  } catch (e) {
    // pop loading circle
    Navigator.pop(context);
    AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: e.toString(),
        padding: const EdgeInsets.only(bottom: Constants.defaultPadding, left: Constants.defaultPadding, right: Constants.defaultPadding)
    ).show();
  }

  if (success) {
    return true;
  } else {
    return false;
  }
}