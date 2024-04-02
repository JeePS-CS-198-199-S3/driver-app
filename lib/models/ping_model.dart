import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_driver/models/route_model.dart';

import '../services/int_to_hex.dart';

class PingData {
  String ping_id;
  String ping_email;
  GeoPoint ping_location;
  int ping_route;
  Timestamp ping_timestamp;

  PingData(
      {required this.ping_id,
        required this.ping_email,
        required this.ping_location,
        required this.ping_route,
        required this.ping_timestamp});

  factory PingData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PingData(
      ping_id: doc.id,
      ping_email: data['ping_email'],
      ping_location: data['ping_location'],
      ping_route: data['ping_route'],
      ping_timestamp: data['ping_timestamp'],
    );
  }

  Map<String, dynamic> toGeoJSONFeature() {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [ping_location.longitude, ping_location.latitude]
      },
    };
  }
}

class PingEntity {
  PingData pingData;
  Circle pingCircle;

  PingEntity({required this.pingData, required this.pingCircle});
}

pingListToGeoJSON(List<PingData> pings) {
  List<Map<String, dynamic>> features =
  pings.map((ping) => ping.toGeoJSONFeature()).toList();

  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'features': features,
  };

  return featureCollection;
}

Future<void> addGeojsonCluster(MapboxMapController mapController, RouteData routeData) async {
  mapController.removeLayer("pings-circles");
  mapController.removeLayer("pings-count");
  mapController.removeSource("pings");
  mapController.addSource(
      "pings",
      GeojsonSourceProperties(
          data: pingListToGeoJSON([]), cluster: true, clusterRadius: 20));
  mapController.addLayer(
      "pings",
      "pings-circles",
      CircleLayerProperties(
          circleColor: intToHexColor(routeData.routeColor),
          circleOpacity: 0.5,
          circleRadius: [
            Expressions.step,
            [Expressions.get, 'point_count'],
            20,
            5,
            30,
            10,
            40
          ]));
  mapController
      .addLayer(
      "pings",
      "pings-count",
      const SymbolLayerProperties(
        textField: [Expressions.get, 'point_count_abbreviated'],
        textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
        textSize: 12,
      ));
  for (int i = 0; i < routeData.routeCoordinates.length; i++) {
    mapController.addLine(LineOptions(
        lineWidth: 4.0,
        lineColor: intToHexColor(routeData.routeColor),
        lineOpacity: 0.5,
        geometry: i != routeData.routeCoordinates.length - 1
            ? [
          routeData.routeCoordinates[i],
          routeData.routeCoordinates[i + 1]
        ]
            : [
          routeData.routeCoordinates[i],
          routeData.routeCoordinates[0]
        ]
    )
    );
  }
}
