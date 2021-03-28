// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifi/main.dart';
import 'package:notifi/notifications/db_provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/screens/settings.dart';
import 'package:notifi/user.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

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
    // not sure why I have to do twice
    await tester.pump(const Duration(seconds: 1));

    // should show that there are new credentials
    expect(find.text('Create New Credentials'), findsOneWidget);

    await expectLater(find.byType(SettingsScreen),
        matchesGoldenFile('golden-asserts/settings.png'));
  });

  testWidgets('Test Notification UI', (WidgetTester tester) async {
    await pumpWidget(
        tester,
        NotificationUI(
            1,
            'title of notification',
            'some time',
            'UUID',
            'message of notification',
            'https://foo.com/jpg',
            'https://max.me.uk/'));

    expect(find.text('No notifications!'), findsNothing);
    expect(find.text('some time'), findsOneWidget);
    expect(find.text('title of notification'), findsOneWidget);
    expect(find.text('message of notification'), findsOneWidget);
    expect(find.byIcon(Icons.link), findsOneWidget);

    await expectLater(find.byType(NotificationUI),
        matchesGoldenFile('golden-asserts/single-notification.png'));
  });
}

Future<void> pumpWidget(
    WidgetTester tester, NotificationUI notification) async {
  WidgetsFlutterBinding.ensureInitialized();
  final DBProvider db = DBProvider('test.db');
  final List<NotificationUI> notifications =
      List<NotificationUI>.empty(growable: true);
  if (notification != null) {
    notifications.add(notification);
  }
  await tester.pumpWidget(MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<ReloadTable>(create: (_) => ReloadTable()),
      ChangeNotifierProxyProvider<ReloadTable, Notifications>(
        create: (BuildContext context) => Notifications(notifications, db,
            Provider.of<ReloadTable>(context, listen: false)),
        update: (BuildContext context, ReloadTable tableNotifier,
                Notifications user) =>
            user..setTableNotifier(tableNotifier),
      ),
      ChangeNotifierProxyProvider<Notifications, User>(
        create: (BuildContext context) =>
            User(Provider.of<Notifications>(context, listen: false), null),
        update:
            (BuildContext context, Notifications notifications, User user) =>
                user..setNotifications(notifications),
      ),
    ],
    child: const MyApp(),
  ));
}
