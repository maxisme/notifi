import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notifications/notification.dart';

Future<FlutterLocalNotificationsPlugin> initLocalNotifications() async {
  final localNotifications = FlutterLocalNotificationsPlugin();

  final settings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: null,
      ),
      macOS: MacOSInitializationSettings(
        defaultPresentAlert: false,
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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

sendLocalNotification(FlutterLocalNotificationsPlugin localNotification, int id,
    NotificationUI notification) {
  var iOS = IOSNotificationDetails();
  var macOS = MacOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(iOS: iOS, macOS: macOS);

  localNotification.show(
      id, notification.title, notification.message, platformChannelSpecifics);
}
