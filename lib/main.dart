import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifi/notifications/db_provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/firebase.dart';
import 'package:notifi/utils/local_notifications.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main({bool integration: false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialise db for linux
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  if (!await loadDotEnv()) {
    // ignore: avoid_print
    print('MISSING REQUIRED ENV VARIABLES');
    exit(1);
  }

  if (Platform.isMacOS) {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await invokeMacMethod(
        'set-pin-window', <String, bool>{'transient': !shouldPinWindow(sp)});
    await invokeMacMethod(
        'set-sparkle-url', <String, String>{'url': versionEndpoint});
  }

  if (shouldUseFirebase && !integration) {
    final AuthorizationStatus status = await initFirebase();
    L.i(status.toString());
  }

  final DBProvider db = DBProvider('notifications.db', templateDB: integration);
  final List<NotificationUI> notifications = await db.getAll();

  FlutterLocalNotificationsPlugin pushNotifications;
  if (!integration) {
    pushNotifications = await initPushNotifications();
  }

  bool canBadge = false;
  if (Platform.isIOS) canBadge = await FlutterAppBadger.isAppBadgeSupported();

  runApp(MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<TableNotifier>(
          create: (BuildContext context) => TableNotifier()),
      ChangeNotifierProxyProvider<TableNotifier, Notifications>(
        create: (BuildContext context) => Notifications(notifications, db,
            Provider.of<TableNotifier>(context, listen: false),
            canBadge: canBadge),
        update: (BuildContext context, TableNotifier tableNotifier,
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
    Provider.of<User>(context, listen: false).loadUser();

    double defaultFontSize = 14;
    double bodyText1FontSize = 10;
    if (Platform.isIOS) {
      defaultFontSize = 17;
      bodyText1FontSize = 14;
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'Inconsolata',
            primaryColor: MyColour.black,
            hoverColor: MyColour.transparent,
            focusColor: MyColour.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            backgroundColor: MyColour.transparent,
            appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(
                  color: MyColour.darkGrey,
                  size: 22,
                ),
                centerTitle: true,
                elevation: 0.0,
                toolbarHeight: 70,
                backgroundColor: MyColour.white),
            iconTheme: const IconThemeData(
              color: MyColour.darkGrey,
              size: 22,
            ),
            scrollbarTheme: ScrollbarThemeData(
              thickness: MaterialStateProperty.all(4.0),
              showTrackOnHover: false,
            ),
            textTheme: TextTheme(
                headline1: TextStyle(
                    inherit: false,
                    textBaseline: TextBaseline.alphabetic,
                    fontFamily: 'Inconsolata',
                    fontSize: defaultFontSize,
                    fontWeight: FontWeight.w600),
                subtitle1: const TextStyle(
                    color: MyColour.grey,
                    fontSize: 10,
                    fontFamily: 'Inconsolata'),
                bodyText1: TextStyle(
                    inherit: false,
                    textBaseline: TextBaseline.alphabetic,
                    fontFamily: 'Inconsolata',
                    color: MyColour.darkGrey,
                    fontSize: bodyText1FontSize,
                    letterSpacing: 0.2,
                    height: 1.2),
                bodyText2: const TextStyle(
                    fontSize: 15,
                    color: MyColour.black,
                    fontWeight: FontWeight.w500,
                    inherit: false,
                    textBaseline: TextBaseline.alphabetic,
                    fontFamily: 'Inconsolata')),
            buttonTheme: const ButtonThemeData(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent),
            textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
            )),
            indicatorColor: MyColour.offOffGrey,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey,
              accentColor: MyColour.red,
            ),
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
