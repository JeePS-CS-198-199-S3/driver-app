

import 'package:permission_handler/permission_handler.dart';


// Requests for Location Permission once called

Future<bool> requestLocationPermission() async {
  PermissionStatus permissionStatus = await Permission.location.request();
  if (permissionStatus == PermissionStatus.granted) {
    return true;
  }
  return false;
}
