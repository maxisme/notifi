// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifi/main.dart';
import 'package:notifi/notifications/db-provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Test No Notifications', (WidgetTester tester) async {
    await pumpWidget(tester, null);
    // first page should show no notifications
    expect(find.text('No notifications!'), findsOneWidget);

    await expectLater(find.byType(HomeScreen),
        matchesGoldenFile('golden-asserts/no-notifications.png'));
  });

  testWidgets('Test Settings Navigation', (WidgetTester tester) async {
    await pumpWidget(tester, null);

    // open settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    await tester.pump(Duration(seconds: 1)); // not sure why I have to do twice

    // should show that there are new credentials
    expect(find.text('Create New Credentials'), findsOneWidget);

    await expectLater(find.byType(SettingsScreen),
        matchesGoldenFile('golden-asserts/settings.png'));
  });


  testWidgets('Test Notification UI', (WidgetTester tester) async {
    await pumpWidget(tester,
        NotificationUI(1, "title of notification", "some time", "UUID", "message of notification", "https://foo.com/jpg", "https://max.me.uk/"));

    expect(find.text('No notifications!'), findsNothing);
    expect(find.text('some time'), findsOneWidget);
    expect(find.text('title of notification'), findsOneWidget);
    expect(find.text('message of notification'), findsOneWidget);
    expect(find.byIcon(Icons.link), findsOneWidget);

    await expectLater(find.byType(NotificationUI),
        matchesGoldenFile('golden-asserts/single-notification.png'));
  });
}

pumpWidget(WidgetTester tester, notification) async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = DBProvider("test.db");
  List<NotificationUI> notifications = List.empty(growable: true);
  if (notification != null) {
    notifications.add(notification);
  }
  await tester.pumpWidget(MultiProvider(
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
            User(Provider.of<Notifications>(context, listen: false), null),
        update: (context, notifications, user) =>
            user..setNotifications(notifications),
      ),
    ],
    child: MyApp(),
  ));
}
