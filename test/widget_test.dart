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
import 'package:notifi/utils/icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  const String time = '2006-01-02 15:04:05';
  // original 2400.0, 1800.0
  const Size physicalSizeTestValue = Size(2200, 1200);

  group('Test Screens', () {
    testWidgets('No Notifications', (WidgetTester tester) async {
      await pumpWidgetWithNotification(tester, null);
      // first page should show no notifications
      expect(find.text('No Notifications!'), findsOneWidget);

      await expectLater(find.byType(HomeScreen),
          matchesGoldenFile('golden-asserts/screen/no-notifications.png'));
    });

    testWidgets('Single Notification', (WidgetTester tester) async {
      await pumpWidgetWithNotification(
          tester,
          NotificationUI(
            title: 'title of notification',
            uuid: '',
            time: time,
          ));
      // first page should show no notifications
      expect(find.text('title of notification'), findsOneWidget);

      await expectLater(find.byType(HomeScreen),
          matchesGoldenFile('golden-asserts/screen/notification.png'));
    });

    testWidgets('Test Settings Navigation', (WidgetTester tester) async {
      await pumpWidgetWithNotification(tester, null);

      // open settings
      await tester.tap(find.byIcon(Akaricons.gear));
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

  group('Test Notifications', () {
    const List<String> titles = <String>[
      'title of notification',
      'title of notification title of notification titl'
    ];
    const List<String> messages = <String>[
      '',
      'message of notification',
      // ignore: no_adjacent_strings_in_list
      'notification '
          'message of notification  message of notification message '
          'of notification message of notification message of notification of '
          'notification message of notification of notificati'
    ];
    const List<String> links = <String>['', 'https://max.me.uk/'];
    const List<String> images = <String>['', 'https://max.me.uk/someimage.jpg'];

    final String longTtl = titles[1];
    final String longMsg = messages[2];

    group('Test Notification Combinations', () {
      for (int a = 0; a < titles.length; a++) {
        for (int b = 0; b < messages.length; b++) {
          for (int c = 0; c < links.length; c++) {
            for (int d = 0; d < images.length; d++) {
              final NotificationUI n = NotificationUI(
                title: titles[a],
                message: messages[b],
                link: links[c],
                image: images[d],
                time: time,
                uuid: '',
              );
              final String name = 'title_$a-message_$b-links_$c-images_$d';
              testWidgets(name, (WidgetTester tester) async {
                tester.binding.window.physicalSizeTestValue =
                    physicalSizeTestValue;

                await pumpWidgetWithNotification(tester, n);
                await tester.pump();

                await expectLater(find.byType(NotificationUI),
                    matchesGoldenFile('golden-asserts/notification/$name.png'));
              });
            }
          }
        }
      }
    });

    testWidgets('Test Mark As Read', (WidgetTester tester) async {
      final NotificationUI n = NotificationUI(
        title: titles[0],
        time: time,
        message: '',
        uuid: '',
      );
      await pumpWidgetWithNotification(tester, n);
      await tester.pump();

      expect(n.isRead, false);
      expect(find.text('1'), findsOneWidget);

      // mark read
      await tester.tap(find.byIcon(Akaricons.check));
      await tester.pump();

      expect(n.isRead, true);
      expect(find.text('1'), findsNothing);

      await expectLater(find.byType(NotificationUI),
          matchesGoldenFile('golden-asserts/notification/is_read.png'));
    });

    testWidgets('Test Expand Action', (WidgetTester tester) async {
      final NotificationUI n = NotificationUI(
        title: longTtl,
        message: longMsg,
        time: time,
        uuid: '',
      );
      await pumpWidgetWithNotification(tester, n);
      await tester.pump();
      await tester.pump();

      expect(n.isExpanded, false);
      expect(n.isRead, false);
      expect(find.text('1'), findsOneWidget);

      // expand
      await tester.tap(find.byIcon(Akaricons.enlarge));
      await tester.pump();

      expect(n.isExpanded, true);
      expect(n.isRead, true);
      expect(find.text('1'), findsNothing);

      await expectLater(find.byType(NotificationUI),
          matchesGoldenFile('golden-asserts/notification/is_expanded.png'));
    });

    group('Test Expand Combinations', () {
      final Map<String, NotificationUI> inputsToBeExpected =
          <String, NotificationUI>{
        'title': NotificationUI(
          time: time,
          uuid: '',
          title: longTtl,
        ),
        'message': NotificationUI(
          time: time,
          uuid: '',
          title: 'foo',
          message: longMsg,
        ),
        'title-message': NotificationUI(
          time: time,
          uuid: '',
          title: longTtl,
          message: longMsg,
        ),
      };
      inputsToBeExpected.forEach((String name, NotificationUI notification) {
        testWidgets(name, (WidgetTester tester) async {
          await pumpWidgetWithNotification(tester, notification);
          await tester.pump();

          expect(find.byIcon(Akaricons.enlarge), findsOneWidget);
        });
      });
    });

    group('Test No Expand Combinations', () {
      final Map<String, NotificationUI> inputsToBeExpected =
          <String, NotificationUI>{
        'title': NotificationUI(
          time: time,
          uuid: '',
          title: longTtl.substring(0, longTtl.length - 1),
        ),
        'message': NotificationUI(
          time: time,
          uuid: '',
          title: 'foo',
          message: longMsg.substring(0, longMsg.length - 1),
        ),
        'title-message': NotificationUI(
          time: time,
          uuid: '',
          title: longTtl.substring(0, longTtl.length - 1),
          message: longMsg.substring(0, longMsg.length - 1),
        ),
      };
      inputsToBeExpected.forEach((String name, NotificationUI notification) {
        testWidgets(name, (WidgetTester tester) async {
          await pumpWidgetWithNotification(tester, notification);
          await tester.pump();

          expect(find.byIcon(Akaricons.enlarge), findsNothing);
        });
      });
    });
  });
}

Future<void> pumpWidgetWithNotification(
    WidgetTester tester, NotificationUI notification) async {
  WidgetsFlutterBinding.ensureInitialized();

  // CHANNEL MOCKS
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      return '';
    }
  });

  const MethodChannel('com.tekartik.sqflite')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getDatabasesPath') {
      return '';
    }
  });

  const MethodChannel('vibration')
      .setMockMethodCallHandler((MethodCall methodCall) async {});
  // finished MOCKS

  final DBProvider db = DBProvider('test.db');
  final List<NotificationUI> notifications =
      List<NotificationUI>.empty(growable: true);
  if (notification != null) {
    notifications.add(notification);
  }

  await tester.pumpWidget(MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<TableNotifier>(create: (_) => TableNotifier()),
      ChangeNotifierProxyProvider<TableNotifier, Notifications>(
        create: (BuildContext context) => Notifications(notifications, db,
            Provider.of<TableNotifier>(context, listen: false),
            canBadge: false),
        update: (BuildContext context, TableNotifier tableNotifier,
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
