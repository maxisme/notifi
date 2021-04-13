import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel platform = MethodChannel('max.me.uk/notifications');
const String refKey = 'ref';
const String messageKey = 'msg';

bool isFlutterTest() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}

Future<dynamic> invokeMacMethod(String method) async {
  if (Platform.isMacOS && !isFlutterTest()) {
    try {
      return await platform.invokeMethod(method);
    } on PlatformException catch (e) {
      L.e("Failed to invoke method ($method): '${e.message}'.");
    }
  }
}

String currentIcon;

class MenuBarIcon {
  static Future<void> set(String icon) async {
    if (icon != 'error') currentIcon = icon;
    await invokeMacMethod('${icon}_menu_icon');
  }

  static Future<void> revert() async {
    String icon = currentIcon;
    if (currentIcon.isEmpty) icon = 'grey';
    set(icon);
  }
}

Future<String> getVersion() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}

bool isBeta() {
  return env['IS_BETA'] == 'true';
}

Future<void> loadDotEnv() async {
  await dot_env.load();
}

Future<void> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
    invokeMacMethod('close_window');
  } else {
    L.w("Can't open: $url");
  }
}

void showToast(String msg, BuildContext context, {int duration, int gravity}) {
  Toast.show(msg, context, duration: duration, gravity: gravity);
}

Future<String> getDeviceUUID() async {
  L.d('fetching UUID');
  return await invokeMacMethod('UUID');
}

class L {
  static void d(String msg) {
    FLog.debug(text: msg);
  }

  static void i(String msg) {
    FLog.info(text: msg);
  }

  static void w(String msg) {
    FLog.warning(text: msg);
  }

  static void e(String msg) {
    FLog.error(text: msg);
  }
}
