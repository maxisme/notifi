// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  group('Test Screens', () {
    testWidgets('No Notifications', (WidgetTester tester) async {
      await pumpWidget(tester, null);
      // first page should show no notifications
      expect(find.text('No notifications!'), findsOneWidget);

      await expectLater(find.byType(HomeScreen),
          matchesGoldenFile('golden-asserts/screen/no-notifications.png'));
    });

    testWidgets('Single Notification', (WidgetTester tester) async {
      await pumpWidget(
          tester,
          NotificationUI(
            title: 'title of notification',
            uuid: '',
            time: '',
          ));
      // first page should show no notifications
      expect(find.text('title of notification'), findsOneWidget);

      await expectLater(find.byType(HomeScreen),
          matchesGoldenFile('golden-asserts/screen/notification.png'));
    });

    testWidgets('Test Settings Navigation', (WidgetTester tester) async {
      await pumpWidget(tester, null);

      const MethodChannel channel =
          MethodChannel('plugins.flutter.io/path_provider');
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '';
        }
      });

      // open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      // not sure why I have to do twice
      await tester.pump(const Duration(seconds: 1));

      // should show that there are new credentials
      expect(find.text('Create New Credentials'), findsOneWidget);

      await expectLater(find.byType(SettingsScreen),
          matchesGoldenFile('golden-asserts/screen/settings.png'));
    });

    // TODO test log navigation
  });

  group('Test Notification', () {
    const String title = 'title of notification';
    const String message = 'message of notification';
    const String link = 'https://max.me.uk/';
    const String image = 'https://max.me.uk/someimage.jpg';
    const String longMsg = 'message of notification message of notification '
        'message of notification message of notification notification messag';
    const String longTtl = 'title of notification title of -';

    final Map<String, NotificationUI> inputsToExpected =
        <String, NotificationUI>{
      'title': NotificationUI(
        title: longTtl.substring(0, longTtl.length - 1),
        uuid: '',
        time: '',
      ),
      'message': NotificationUI(
        title: title,
        message: longMsg.substring(0, longMsg.length - 1),
        uuid: '',
        time: '',
      ),
      'link': NotificationUI(
        title: title,
        message: message,
        link: link,
        uuid: '',
        time: '',
      ),
      'image': NotificationUI(
        title: title,
        message: message,
        link: link,
        image: image,
        uuid: '',
        time: '',
      ),
      'overflow-title': NotificationUI(
        title: longTtl,
        uuid: '',
        time: '',
      ),
      'overflow-message': NotificationUI(
        title: 'title of notification',
        message: longMsg,
        uuid: '',
        time: '',
      ),
    };
    inputsToExpected.forEach((String name, NotificationUI notification) {
      testWidgets(name, (WidgetTester tester) async {
        // original 2400.0, 1800.0
        tester.binding.window.physicalSizeTestValue = const Size(1500, 600);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await pumpWidget(tester, notification);
        await tester.pump();

        if (name.contains('overflow')) {
          expect(find.byIcon(Icons.expand), findsOneWidget);
        } else {
          expect(find.byIcon(Icons.expand), findsNothing);
        }

        await expectLater(find.byType(NotificationUI),
            matchesGoldenFile('golden-asserts/notification/$name.png'));
      });
    });

    testWidgets('Test Mark As Read', (WidgetTester tester) async {
      final NotificationUI n = NotificationUI(
        title: title,
        message: '',
        uuid: '',
        time: '',
      );
      await pumpWidget(tester, n);
      await tester.pump();

      expect(n.isRead, false);

      // mock db call
      const MethodChannel channel = MethodChannel('com.tekartik.sqflite');
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return '';
        }
      });

      // mark read
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(n.isRead, true);

      await expectLater(find.byType(NotificationUI),
          matchesGoldenFile('golden-asserts/notification/read.png'));
    });

    testWidgets('Test Expand', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1500, 600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final NotificationUI n = NotificationUI(
        title: longTtl,
        message: '',
        uuid: '',
        time: '',
      );
      await pumpWidget(tester, n);
      await tester.pump();
      await tester.pump();

      expect(n.isExpanded, false);

      // mock db call (as expanding marks as read)
      const MethodChannel channel = MethodChannel('com.tekartik.sqflite');
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return '';
        }
      });

      // mark read
      await tester.tap(find.byIcon(Icons.expand));
      await tester.pump();

      expect(n.isExpanded, true);

      await expectLater(find.byType(NotificationUI),
          matchesGoldenFile('golden-asserts/notification/expand.png'));
    });
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
