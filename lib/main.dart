import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notifi/local-notifications.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:notifi/ws.dart';

import 'notifications/notification-provider.dart';

void main() async {
  await DotEnv().load();

  WidgetsFlutterBinding.ensureInitialized();

  final notificationDB = NotificationProvider();
  notificationDB.open("notifications.db");

  final user = await fetchUser();
  var nt = new NotificationTable(user, notificationDB);
  await initWS(user, await initLocalNotifications(), nt);
  runApp(MyApp(nt));
}

class MyApp extends StatefulWidget {
  NotificationTable table;

  MyApp(this.table, {Key key}) : super(key: key);

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
          '/': (context) => HomeScreen(widget.table),
          '/settings': (context) => SettingsScreen(widget.table),
        });
  }
}
