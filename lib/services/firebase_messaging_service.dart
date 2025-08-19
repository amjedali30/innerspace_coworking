import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getDeviceToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("🔥 FCM Device Token: $token");
  return token;
}
