import 'package:cloud_firestore/cloud_firestore.dart';

class Routes {
  final String route_name;
  final int route_id;
  final bool enabled;
  final int route_color;
  final List<GeoPoint> route_coordinates;
  final double route_fare;
  final double route_fare_discounted;
  final List<int> route_time;


  Routes({required this.route_name, required this.route_id, required this.enabled, required this.route_color, required this.route_coordinates, required this.route_fare, required this.route_fare_discounted, required this.route_time});

  factory Routes.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String routeName = data['route_name'];
    int routeId = data['route_id'];
    bool enabled = data['enabled'];
    int routeColor = data['route_color'];
    List<GeoPoint> routeCoordinates = List.castFrom<dynamic, GeoPoint>(data['route_coordinates']);
    double routeFare = data['route_fare'];
    double routeFareDiscounted = data['route_fare_discounted'];
    List<int> routeTime = List.castFrom<dynamic, int>(data['route_time']);


    return Routes(
      route_name: routeName,
      route_id: routeId,
      enabled: enabled,
      route_color: routeColor,
      route_coordinates: routeCoordinates,
      route_fare: routeFare,
      route_fare_discounted: routeFareDiscounted,
      route_time: routeTime
    );
  }
}

