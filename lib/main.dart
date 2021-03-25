import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils.dart';

import 'local-notifications.dart';
import 'notifications/notification-provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DotEnv.load(fileName: ".env");

  var user = User();
  var nt = NotificationTable(user);
  var db = NotificationProvider();
  var homeScreen = HomeScreen(nt, db);

  runApp(MyApp(homeScreen, user));

  // connect to websocket
  await user.create();
  user.ws = await connectToWs(user, await initLocalNotifications(), homeScreen);
}

class MyApp extends StatefulWidget {
  final HomeScreen homeScreen;
  final User user;

  MyApp(this.homeScreen, this.user, {Key key}) : super(key: key);

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
            highlightColor: MyColour.transparent,
            hoverColor: MyColour.transparent,
            splashColor: MyColour.transparent,
            accentColor: MyColour.black,
            buttonColor: MyColour.red,
            focusColor: MyColour.transparent,
            dialogTheme: DialogTheme(
                elevation: 0,
                shape: Border.all(width: 3),
                contentTextStyle: TextStyle(
                  fontFamily: 'Inconsolata',
                  color: MyColour.black,
                  fontWeight: FontWeight.w500,
                ),
                titleTextStyle: TextStyle(
                    fontFamily: 'Inconsolata',
                    color: MyColour.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 35))),
        routes: {
          '/': (context) => widget.homeScreen,
          '/settings': (context) => SettingsScreen(widget.user),
        });
  }
}

