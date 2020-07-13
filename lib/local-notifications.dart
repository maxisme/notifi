import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<FlutterLocalNotificationsPlugin> initLocalNotifications() async {
  final localNotifications = FlutterLocalNotificationsPlugin();

  final settings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: null,
      ),
      macOS: MacOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ));

  await localNotifications.initialize(settings);

  await localNotifications
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  return localNotifications;
}

sendLocalNotification(
  FlutterLocalNotificationsPlugin localNotification,
  int id,
  String title,
  String body, {
  String payload,
}) {
  var iOS = IOSNotificationDetails();
  var macOS = MacOSNotificationDetails();
  var platformChannelSpecifics =
      NotificationDetails(iOS: iOS, macOS: macOS);

  localNotification.show(id, title, body, platformChannelSpecifics,
      payload: payload);
}
