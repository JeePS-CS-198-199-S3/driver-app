import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../services/mapbox.dart';
import '../style/constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap;

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        resourceOptions: ResourceOptions(
          accessToken: accessToken
        ),
        onMapCreated: _onMapCreated,
        styleUri: mapStyle,
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(14.655072, 121.068578)).toJson(),
          padding: MbxEdgeInsets(top: Constants.defaultPadding, left: Constants.defaultPadding, bottom: Constants.defaultPadding, right: Constants.defaultPadding),
          zoom: 20.0
        ),
      )
    );
  }
}
