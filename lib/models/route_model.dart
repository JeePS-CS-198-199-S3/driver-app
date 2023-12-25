import 'package:cloud_firestore/cloud_firestore.dart';

class Routes {
  final String routeName;
  final int routeId;
  final bool enabled;
  final int routeColor;
  final List<GeoPoint> routeCoordinates;
  final double routeFare;
  final double routeFareDiscounted;
  final List<int> routeTime;


  Routes({required this.routeName, required this.routeId, required this.enabled, required this.routeColor, required this.routeCoordinates, required this.routeFare, required this.routeFareDiscounted, required this.routeTime});

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
      routeName: routeName,
      routeId: routeId,
      enabled: enabled,
      routeColor: routeColor,
      routeCoordinates: routeCoordinates,
      routeFare: routeFare,
      routeFareDiscounted: routeFareDiscounted,
      routeTime: routeTime
    );
  }
}

