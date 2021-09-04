import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;


void main() {
  group('SS', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await setupAndGetDriver();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      driver.close();
      exit(0);
    });

    test('SS screens', () async {
      SerializableFinder deleteAll = find.byValueKey('delete-all');
      SerializableFinder ok = find.byValueKey('ok');
      SerializableFinder toggleExpand = find.byValueKey('toggle-expand');

      // ss notifications
      await driver.waitFor(toggleExpand);
      await driver.tap(toggleExpand);
      await sleep(Duration(seconds: 1));
      await screenshot(driver, 'screenshots/1.png');

      // ss no notifications
      await driver.tap(deleteAll);
      await driver.waitFor(ok);
      await driver.tap(ok);
      await screenshot(driver, 'screenshots/2.png');

      // Send & Receive notifications

      // get credentials
      SerializableFinder credentials = find.byValueKey('credentials');
      String creds = await driver.getText(credentials);

      // send request
      http.Response req = await http.get(Uri.parse('https://dev.notifi.it/api?credentials=$creds&title=1Lorem ipsum dolor.&message=Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.&link=https://notifi.it&image=https://notifi.it/images/logo.png'));
      // ignore: avoid_print
      print(req.statusCode);
      req = await http.get(Uri.parse('https://dev.notifi.it/api?credentials=$creds&title=2Lorem ipsum dolor.&message=Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.&link=https://notifi.it&image=https://notifi.it/images/logo.png'));
      req = await http.get(Uri.parse('https://dev.notifi.it/api?credentials=$creds&title=3Lorem ipsum dolor.&message=Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.&link=https://notifi.it&image=https://notifi.it/images/logo.png'));
      // ignore: avoid_print
      print(req.statusCode);

      // wait for notification to appear
      SerializableFinder notification = find.byValueKey('notification');
      await driver.waitFor(notification);
    });
  });
}

Future<FlutterDriver> setupAndGetDriver() async {
  FlutterDriver driver = await FlutterDriver.connect();
  bool connected = false;
  while (!connected) {
    try {
      await driver.waitUntilFirstFrameRasterized();
      connected = true;
    } catch (error) {}
  }
  return driver;
}

Future<void> screenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = File(path);
  await file.writeAsBytes(pixels);
}
