import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

Future<void> addImagesFromAsset(MapboxMapController mapController) async {
  final ByteData jeepBytes = await rootBundle.load("lib/images/jeep.png");
  final Uint8List jeepList = jeepBytes.buffer.asUint8List();

  final ByteData accidentBytes = await rootBundle.load("lib/images/jeep.png");
  final Uint8List accidentList = accidentBytes.buffer.asUint8List();

  final ByteData crimeBytes = await rootBundle.load("lib/images/jeep.png");
  final Uint8List crimeList = crimeBytes.buffer.asUint8List();

  final ByteData mechErrorBytes = await rootBundle.load("lib/images/jeep.png");
  final Uint8List mechErrorList = mechErrorBytes.buffer.asUint8List();

  await mapController.addImage("jeepTop", jeepList);
  await mapController.addImage("accident", accidentList);
  await mapController.addImage("crime", crimeList);
  await mapController.addImage("mechError", mechErrorList);
}
