import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  PermissionStatus permissionStatus = await Permission.location.request();

  if (permissionStatus == PermissionStatus.granted) {
    // Permission Granted
  } else if (permissionStatus == PermissionStatus.denied) {
    // Permission Denied
    // You might want to show a dialog explaining why the app needs location
  } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
    // Permission Permanently Denied
    // The user opted to never again be asked for this permission
    // You might want to direct the user to the app settings
  }
}
