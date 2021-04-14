import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// https://firebase.flutter.dev/docs/installation/ios/

Future<AuthorizationStatus> initFirebase() async {
  Firebase.initializeApp();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final NotificationSettings settings = await messaging.requestPermission();
  // TODO reload websocket
  // FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  return settings.authorizationStatus;
}
