import 'package:flutter/material.dart';
import 'package:innerspace_coworking/constatnt/constant.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/bookingProvider.dart';
import 'providers/branch_provider.dart';
import 'providers/notificationProvider.dart';
import 'screens/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/firebase_messaging_service.dart';
import 'services/notificationSerivice.dart';
// import 'providers/booking_provider.dart';
// import 'providers/notification_provider.dart';
// import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize(oneSignalAppId);
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coworking Space Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
