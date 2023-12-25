import 'package:cloud_firestore/cloud_firestore.dart';

List<GeoPoint> geoPoints = [
  GeoPoint(14.657675, 121.062360),
  GeoPoint(14.654756, 121.062316),
  GeoPoint(14.647361, 121.062336),
  GeoPoint(14.647706, 121.063844),
  GeoPoint(14.647659, 121.064632),
  GeoPoint(14.647939, 121.065780),
  GeoPoint(14.647960, 121.066328),
  GeoPoint(14.647254, 121.067808),
  GeoPoint(14.647173, 121.068955),
  GeoPoint(14.649071, 121.068951),
  GeoPoint(14.649904, 121.068611),
  GeoPoint(14.650504, 121.068453),
  GeoPoint(14.650908, 121.068430),
  GeoPoint(14.651842, 121.068584),
  GeoPoint(14.652487, 121.068667),
  GeoPoint(14.652550, 121.072847),
  GeoPoint(14.653974, 121.072828),
  GeoPoint(14.654645, 121.073132),
  GeoPoint(14.655566, 121.073090),
  GeoPoint(14.656308, 121.072771),
  GeoPoint(14.659379, 121.072722),
  GeoPoint(14.659390, 121.068572),
  GeoPoint(14.657539, 121.068584),
  GeoPoint(14.657568, 121.064787),
  GeoPoint(14.657675, 121.062360),
];

Future<void> addRouteToFirestore(data) async {
  try {
    // Reference to the 'routes' collection
    CollectionReference routes = FirebaseFirestore.instance.collection('routes');

    // Add a new document with an auto-generated ID
    await routes.add(data);

    print('Route added successfully!');
  } catch (e) {
    print('Error adding route: $e');
  }
}

Future<void> createRoute() async {
  // Create a Route object

  Map<String, dynamic> data = {
    'route_name': 'Ikot',
    'route_id': 0,
    'enabled': true,
    'route_color': 0xFFFFC107,
    'route_fare': 11.0,
    'route_fare_discounted': 10.0,
    'route_time': [480, 1020],
    'route_coordinates': geoPoints
  };

  await addRouteToFirestore(data);
}