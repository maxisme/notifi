import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:notifi/ws.dart';

import 'local-notifications.dart';

void main() async {
  await DotEnv().load();

  WidgetsFlutterBinding.ensureInitialized();
  var user = new User();
  var nt = new NotificationTable(user);

  // connect to websocket
  user.ws = await connectToWs(user, await initLocalNotifications(), nt);

  runApp(MyApp(nt, user));
}

class MyApp extends StatefulWidget {
  final NotificationTable table;
  final User user;

  MyApp(this.table, this.user, {Key key}) : super(key: key);

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
          '/settings': (context) => SettingsScreen(widget.user),
        });
  }
}
