import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;


void main() {
  group('Screen Shot', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await setupAndGetDriver();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      await driver.close();
    });

    test('SS screens', () async {
      SerializableFinder toggleExpand = find.byValueKey('toggle-expand');

      // ss notifications
      await driver.waitFor(toggleExpand);
      await driver.tap(toggleExpand);
      await driver.waitUntilNoTransientCallbacks(timeout: Duration(seconds: 5));
      await screenshot(driver, 'screenshots/1.png');
    });

    test('Screenshot no notifications', () async {
      SerializableFinder deleteAll = find.byValueKey('delete-all');
      SerializableFinder ok = find.byValueKey('ok');
      // ss no notifications
      await driver.tap(deleteAll);
      await driver.waitFor(ok);
      await driver.tap(ok);
      await driver.waitUntilNoTransientCallbacks(timeout: Duration(seconds: 5));
      await screenshot(driver, 'screenshots/2.png');
    });

    test('Test new credentials', () async {
      SerializableFinder credentials = find.byValueKey('credentials');
      SerializableFinder cog = find.byValueKey('cog');
      SerializableFinder back = find.byValueKey('back-button');
      SerializableFinder newCredentials = find.byValueKey('new-credentials');
      SerializableFinder ok = find.byValueKey('ok');


      await driver.waitFor(credentials);
      String initialCreds = await driver.getText(credentials);

      await driver.waitFor(cog);
      await driver.tap(cog);

      await driver.waitUntilNoTransientCallbacks(timeout: Duration(seconds: 5));
      await screenshot(driver, 'screenshots/3.png');

      await driver.waitFor(newCredentials);
      await driver.tap(newCredentials);

      await driver.waitFor(ok);
      await driver.tap(ok);

      await driver.waitFor(back);
      await driver.tap(back);

      await Future<Duration>.delayed(Duration(seconds: 2));

      await driver.waitFor(credentials);
      String updatedCreds = await driver.getText(credentials);

      expect(updatedCreds != initialCreds, true);
    });

    test('Test receiving notifications and scroll', () async {
      // Send & Receive notifications

      // get credentials
      SerializableFinder credentials = find.byValueKey('credentials');
      String creds = await driver.getText(credentials);

      // ignore: avoid_print
      print(creds);

      // get host from .env
      String host;
      String file = await File('.env').readAsString();
      file.split('\n').forEach((String ln){
        if(ln.startsWith('HOST=')){
          host = ln.replaceAll('HOST=', '');
        }
      });

      // send request
      for (int i = 1; i <= 10; i++) {
        http.Response req = await http.get(Uri.parse(
            'https://$host/api?credentials=$creds&title=${i}&message=Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.&link=https://notifi.it&image=https://notifi.it/images/logo.png'));
        // ignore: avoid_print
        print(req.statusCode);
        await Future<Duration>.delayed(Duration(milliseconds: 600));
      }

      await driver.waitUntilNoTransientCallbacks(timeout: Duration(seconds: 2));

      // wait for notification to appear
      SerializableFinder notification = find.text('5');
      await driver.waitFor(notification);
      await driver.scrollIntoView(notification);
      await driver.waitUntilNoTransientCallbacks(timeout: Duration(seconds: 2));
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
