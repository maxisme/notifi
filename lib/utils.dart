import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel platform = MethodChannel('max.me.uk/notifications');
const String refKey = 'ref';
const String messageKey = 'msg';

bool isTest() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}

Future<void> invokeMacMethod(String method) async {
  if (Platform.isMacOS && !isTest()) {
    try {
      await platform.invokeMethod(method);
    } on PlatformException catch (e) {
      print("Failed to invoke method ($method): '${e.message}'.");
    }
  }
}

Future<String> getVersionFromPubSpec() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}

Future<void> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
    invokeMacMethod('close_window');
  } else {
    print("can't open: $url");
  }
}

void showToast(String msg, BuildContext context, {int duration, int gravity}) {
  Toast.show(msg, context, duration: duration, gravity: gravity);
}
