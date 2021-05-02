import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifi/utils/local_notifications.dart';
import 'package:notifi/notifications/db_provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/firebase.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadDotEnv();

  if (shouldUseFirebase()) {
    final AuthorizationStatus status = await initFirebase();
    L.i(status.toString());
  }

  final DBProvider db = DBProvider('notifications.db');
  final List<NotificationUI> notifications = await db.getAll();
  final FlutterLocalNotificationsPlugin pushNotifications =
      await initPushNotifications();

  bool canBadge = false;
  if (Platform.isIOS) canBadge = await FlutterAppBadger.isAppBadgeSupported();

  runApp(MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<ReloadTable>(
          create: (BuildContext context) => ReloadTable()),
      ChangeNotifierProxyProvider<ReloadTable, Notifications>(
        create: (BuildContext context) => Notifications(
            notifications, db, Provider.of<ReloadTable>(context, listen: false),
            canBadge: canBadge),
        update: (BuildContext context, ReloadTable tableNotifier,
                Notifications user) =>
            user..setTableNotifier(tableNotifier),
      ),
      ChangeNotifierProxyProvider<Notifications, User>(
        create: (BuildContext context) => User(
            Provider.of<Notifications>(context, listen: false),
            pushNotifications),
        update:
            (BuildContext context, Notifications notifications, User user) =>
                user..setNotifications(notifications),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: 'Inconsolata',
            primaryColor: MyColour.offWhite,
            hoverColor: MyColour.transparent,
            focusColor: MyColour.transparent,
            accentColor: MyColour.black,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey,
            ).copyWith(),
            dialogTheme: DialogTheme(
                elevation: 0,
                shape: Border.all(width: 3),
                contentTextStyle: const TextStyle(
                  fontFamily: 'Inconsolata',
                  color: MyColour.black,
                  fontWeight: FontWeight.w500,
                ),
                titleTextStyle: const TextStyle(
                    fontFamily: 'Inconsolata',
                    color: MyColour.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 35))),
        routes: <String, Widget Function(BuildContext)>{
          '/': (BuildContext context) => HomeScreen(),
          '/settings': (BuildContext context) => const SettingsScreen(),
        });
  }
}
