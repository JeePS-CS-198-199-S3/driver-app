import 'package:flutter/material.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

import '../services/mapbox.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // MapboxMap? mapboxMap;
  //
  // _onMapCreated(MapboxMap mapboxMap) {
  //   this.mapboxMap = mapboxMap;
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text(
       "Map"
      )
      // body: MapboxMap(
      //   accessToken: "pk.eyJ1IjoiemVkZWMiLCJhIjoiY2xoZzdidjc1MDIxMDNsbnpocmloZXczeSJ9.qsTTfBC6ZB9ncP2rvbCnIw",
      //   styleString: 'mapbox://styles/zedec/clhg7iztv00gq01rh5efqhzz5',
      //   initialCameraPosition: const CameraPosition(
      //     target: LatLng(14.653836, 121.068427),
      //     zoom: 15
      //   ),
      // )
    );
  }
}
