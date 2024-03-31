import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class RouteData {
  bool enabled;
  int routeColor;
  List<LatLng> routeCoordinates;
  num routeFare;
  num routeFareDiscounted;
  int routeId;
  String routeName;
  List<int> routeTime;
  bool isClockwise;

  RouteData({
    required this.enabled,
    required this.routeColor,
    required this.routeCoordinates,
    required this.routeFare,
    required this.routeFareDiscounted,
    required this.routeId,
    required this.routeName,
    required this.routeTime,
    required this.isClockwise
  });

  factory RouteData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return RouteData(
        enabled: data['enabled'] ?? false,
        routeColor: data['route_color'] ?? 0,
        routeCoordinates: (data['route_coordinates'] as List<dynamic>)
            .map((coord) => _parseGeoPointToLatLng(coord as GeoPoint))
            .toList(),
        routeFare: data['route_fare'] ?? 0.0,
        routeFareDiscounted: data['route_fare_discounted'] ?? 0.0,
        routeId: data['route_id'] ?? 0,
        routeName: data['route_name'] ?? '',
        routeTime: (data['route_time'] as List<dynamic>)
            .map((time) => time as int)
            .toList(),
        isClockwise: data['is_clockwise'] as bool
    );
  }

  static GeoPoint fromMap(Map<String, dynamic> map) {
    return GeoPoint(
        map['latitude'],
        map['longitude']
    );
  }

  static LatLng _parseGeoPointToLatLng(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  static Future<RouteData?> fetchRouteData(int routeId) async {
    try {
      CollectionReference jeepsCollection = FirebaseFirestore.instance.collection('routes');
      QuerySnapshot querySnapshot = await jeepsCollection.where('route_id', isEqualTo: routeId).get();

      if (querySnapshot.docs.isNotEmpty) {
        return RouteData.fromFirestore(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching jeep data: $e');
      return null;
    }
  }

  static Future<List<RouteData>?> fetchRoutes() async {
    try {
      CollectionReference routesCollection = FirebaseFirestore.instance.collection('routes');
      QuerySnapshot routesQuerySnapshot = await routesCollection.orderBy('route_id').get();

      if (routesQuerySnapshot.docs.isNotEmpty) {
        return routesQuerySnapshot.docs.map((e) => RouteData.fromFirestore(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching jeep data: $e');
      return null;
    }
  }
}
