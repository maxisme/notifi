import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

const platform = const MethodChannel('max.me.uk/notifications');
const refKey = "ref";
const messageKey = "msg";

bool isTest() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}

Future<void> invokeMacMethod(method) async {
  if (Platform.isMacOS && !isTest()) {
    try {
      await platform.invokeMethod(method);
    } on PlatformException catch (e) {
      print("Failed to invoke method ($method): '${e.message}'.");
    }
  }
}

Future<String> getVersionFromPubSpec() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}

openUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
    invokeMacMethod("close_window");
  } else {
    print("can't open: " + url);
  }
}
