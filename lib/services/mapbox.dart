import 'package:mapbox_gl/mapbox_gl.dart';

import '../models/driver_emergency_model.dart';

const accessToken = 'pk.eyJ1IjoiemVkZWMiLCJhIjoiY2xoZzdidjc1MDIxMDNsbnpocmloZXczeSJ9.qsTTfBC6ZB9ncP2rvbCnIw';
const mapStyle = 'mapbox://styles/zedec/clhlz7j8z00kr01pp5she116z';
const initialCameraPosition = LatLng(14.653836, 121.068427);
const double zoom = 15.0;

// in seconds
const sosLifespan = 60;

const CircleOptions tappedDriverEmergency = CircleOptions(
  circleOpacity: 1,
  circleStrokeWidth: 3,
  circleRadius: 10,
  circleStrokeColor: "#FFFFFF",
  circleStrokeOpacity: 1
);

const CircleOptions untappedDriverEmergency = CircleOptions(
    circleOpacity: 0.5,
    circleStrokeWidth: 0,
    circleRadius: 10,
    circleStrokeOpacity: 0
);