import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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
