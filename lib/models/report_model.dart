import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class ReportData {
  String report_id;
  String report_sender;
  String report_recepient;
  String report_jeepney;
  Timestamp timestamp;
  String report_content;
  int report_type;
  GeoPoint report_location;
  int report_route;

  ReportData(
      {required this.report_id,
        required this.report_sender,
        required this.report_recepient,
        required this.report_jeepney,
        required this.timestamp,
        required this.report_content,
        required this.report_type,
        required this.report_route,
        required this.report_location});

  factory ReportData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ReportData(
      report_id: doc.id,
      report_sender: data['report_sender'] ?? '',
      report_recepient: data['report_recepient'] ?? '',
      report_jeepney: data['report_jeepney'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      report_content: data['report_content'] ?? '',
      report_type: data['report_type'] ?? 0,
      report_route: data['report_route'],
      report_location: data['report_location'],
    );
  }

  static List<ReportDetails> reportDetails = [
    ReportDetails(reportType: 'Lost Item', reportColors: Colors.lightBlue),
    ReportDetails(reportType: 'Crime Incident', reportColors: Colors.red),
    ReportDetails(
        reportType: 'Mechanical Failure', reportColors: Colors.yellow),
    ReportDetails(reportType: 'Accident', reportColors: Colors.orange),
    ReportDetails(reportType: 'Other Concerns', reportColors: Colors.lightBlue),
  ];
}

class ReportDetails {
  String reportType;
  Color reportColors;

  ReportDetails({required this.reportType, required this.reportColors});
}

class ReportEntity {
  ReportData reportData;
  Circle reportCircle;

  ReportEntity({required this.reportData, required this.reportCircle});
}
