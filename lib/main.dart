import 'package:flutter/material.dart';
import 'package:notifi/notifications/db-provider.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var db = DBProvider();
  var notifications = await db.getAll();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ReloadTable>(create: (_) => ReloadTable()),
      ChangeNotifierProxyProvider<ReloadTable, Notifications>(
        create: (context) => Notifications(notifications, db,
            Provider.of<ReloadTable>(context, listen: false)),
        update: (context, tableNotifier, user) =>
            user..setTableNotifier(tableNotifier),
      ),
      ChangeNotifierProxyProvider<Notifications, User>(
        create: (context) =>
            User(Provider.of<Notifications>(context, listen: false)),
        update: (context, notifications, user) =>
            user..setNotifications(notifications),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

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
          '/': (context) => HomeScreen(),
          '/settings': (context) => SettingsScreen(),
        });
  }
}
