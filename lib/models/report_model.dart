import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../services/int_to_hex.dart';

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

  Map<String, dynamic> toGeoJSONFeature() {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [report_location.longitude, report_location.latitude]
      },
    };
  }
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

reportListToGeoJSON(List<ReportData> SOSList) {
  List<Map<String, dynamic>> features =
  SOSList.map((SOS) => SOS.toGeoJSONFeature()).toList();

  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'features': features,
  };

  return featureCollection;
}

Future<void> addGeojsonSOS(MapboxMapController mapController) async {
  double radius = 50;
  mapController.removeLayer("accidents-icons");
  mapController.removeSource("accidents");
  mapController.removeLayer("crime-icons");
  mapController.removeSource("crime");
  mapController.removeLayer("mechError-icons");
  mapController.removeSource("mechError");

  mapController.addSource(
      "mechError",
      GeojsonSourceProperties(
          data: reportListToGeoJSON([]), cluster: true, clusterRadius: radius));
  mapController.addLayer(
      "mechError",
      "mechError-icons",
      const SymbolLayerProperties(
          iconImage: 'mechError',
          textField: [Expressions.get, 'point_count_abbreviated'],
          textAllowOverlap: true,
          iconAllowOverlap: true,
          textOffset: [0, 50],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 13,
          iconSize: 0.12));

  mapController.addSource(
      "accidents",
      GeojsonSourceProperties(
          data: reportListToGeoJSON([]), cluster: true, clusterRadius: radius));
  mapController.addLayer(
      "accidents",
      "accidents-icons",
      const SymbolLayerProperties(
          iconImage: 'accident',
          iconAllowOverlap: true,
          textField: [Expressions.get, 'point_count_abbreviated'],
          textAllowOverlap: true,
          textOffset: [0, 50],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 13,
          iconSize: 0.12));

  mapController.addSource(
      "crime",
      GeojsonSourceProperties(
          data: reportListToGeoJSON([]), cluster: true, clusterRadius: radius));
  mapController.addLayer(
      "crime",
      "crime-icons",
      const SymbolLayerProperties(
          iconImage: 'crime',
          textField: [Expressions.get, 'point_count_abbreviated'],
          textAllowOverlap: true,
          iconAllowOverlap: true,
          textOffset: [0, 50],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 13,
          iconSize: 0.12));
}