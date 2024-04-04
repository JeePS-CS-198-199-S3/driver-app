

import 'package:permission_handler/permission_handler.dart';


Future<bool> requestLocationPermission() async {
  PermissionStatus permissionStatus = await Permission.location.request();
  if (permissionStatus == PermissionStatus.granted) {
    return true;
  }
  return false;
}
