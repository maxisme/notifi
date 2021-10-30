import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_icon_badge/flutter_app_icon_badge.dart';
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

Future<void> main() => mainImpl();

Future<void> mainImpl({bool integration: false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sp = await SharedPreferences.getInstance();
  Globals.isIntegration = integration;

  // initialise db for linux & windows
  if (!isTest && (Platform.isWindows || Platform.isLinux)) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  if (!isTest && !await loadDotEnv()) {
    // ignore: avoid_print
    print('MISSING REQUIRED ENV VARIABLES');
    exit(1);
  }

  if (Platform.isMacOS) {
    await invokeMacMethod(
        'set-pin-window', <String, bool>{'transient': !shouldPinWindow(sp)});
    await invokeMacMethod(
        'set-sparkle-url', <String, String>{'url': versionEndpoint});
  } else if (Platform.isLinux) {
    // see my_application.cc for window size
    await DesktopWindow.setMinWindowSize(Size(425, 720));
  }

  if (!integration && shouldUseFirebase) {
    final AuthorizationStatus status = await initFirebase();
    L.i(status.toString());
  }

  final DBProvider db =
      DBProvider('notifications.db', fillWithNotifications: integration);
  final List<NotificationUI> notifications = await db.getAll();

  FlutterLocalNotificationsPlugin pushNotifications = null;
  if (!integration) {
    pushNotifications = await initPushNotifications();
  }

  bool canBadge;
  try {
    canBadge = await FlutterAppIconBadge.isAppBadgeSupported();
  } catch (_) {
    canBadge = false;
  }

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
  void initState() {
    Provider.of<User>(context, listen: false).loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                shape: Border.all(width: 0, color: MyColour.offOffGrey),
                contentTextStyle: const TextStyle(
                  fontFamily: 'Inconsolata',
                  color: MyColour.black,
                  fontWeight: FontWeight.w500,
                ),
                titleTextStyle: const TextStyle(
                    fontFamily: 'Inconsolata',
                    color: MyColour.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 30))),
        routes: <String, Widget Function(BuildContext)>{
          '/': (BuildContext context) => HomeScreen(),
          '/settings': (BuildContext context) => const SettingsScreen(),
        });
  }
}
