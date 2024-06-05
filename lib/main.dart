import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:transitrack_driver/pages/auth_page.dart';
import 'package:transitrack_driver/style/constants.dart';
import 'firebase_options.dart';
import 'menu_controller.dart';

final FlutterLocalNotificationsPlugin flutterLocalPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
  "JeePS Driver App",
  "JeePS Driver App Service",
  description: "Notifies whether the application is broadcasting.",
  importance: Importance.high
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initService();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterDisplayMode.setHighRefreshRate();
  runApp(const MyApp());
}

Future<void> initService() async {

  // For background services
  var service = FlutterBackgroundService();
  await flutterLocalPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(notificationChannel);

  await service.configure(
    iosConfiguration: IosConfiguration(
      onBackground: iosBackground,
      onForeground: onStart
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: false,
      initialNotificationTitle: "JeePS Driver App Notifier",
      initialNotificationContent: "Notifies whether the application is broadcasting.",
      foregroundServiceNotificationId: 90
  ));
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  service.on("stopService").listen((event) async {
    await flutterLocalPlugin.cancel(90);
    service.stopSelf();
  });

  flutterLocalPlugin.show(
      90,
      "You are currently operating. Drive safe!",
      "Please keep the app open to continue broadcasting.",
      const NotificationDetails(android: AndroidNotificationDetails("JeePS Driver App", "JeePS Driver App Service",
          ongoing: true, icon: "app_icon", importance: Importance.high)));
  
}

@pragma("vm:entry-point")
Future<bool> iosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Constants.secondaryColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: Constants.secondaryColor),
      themeMode: ThemeMode.dark,
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => MenuControllers(),
            ),
          ],
          child: const AuthPage()),
    );
  }
}