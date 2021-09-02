import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifi/notifications/notification.dart';

Future<FlutterLocalNotificationsPlugin> initPushNotifications() async {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(defaultPresentAlert: false),
      macOS: MacOSInitializationSettings(
        defaultPresentAlert: false,
      ),
      linux: LinuxInitializationSettings(
          defaultActionName: 'defaultActionName',
          defaultSound: ThemeLinuxSound('message'),
          defaultIcon: AssetsLinuxIcon('images/bell.png')));

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

void sendLocalNotification(FlutterLocalNotificationsPlugin localNotification,
    int id, NotificationUI notification) {
  const IOSNotificationDetails iOS = IOSNotificationDetails();
  const MacOSNotificationDetails macOS = MacOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(iOS: iOS, macOS: macOS);

  localNotification.show(
      id, notification.title, notification.message, platformChannelSpecifics);
}
