import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel platform = MethodChannel('max.me.uk/notifications');
const String refKey = 'ref';
const String messageKey = 'msg';

bool isTest() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}

Future<dynamic> invokeMacMethod(String method) async {
  if (Platform.isMacOS && !isTest()) {
    try {
      return await platform.invokeMethod(method);
    } on PlatformException catch (e) {
      L.e("Failed to invoke method ($method): '${e.message}'.");
    }
  }
}

String currentIcon;
bool hasErr = false;

class MenuBarIcon {
  static Future<void> set(String icon) async {
    if (!hasErr) {
      await invokeMacMethod('${icon}_menu_icon');
    }
    if (icon != 'error') currentIcon = icon;
  }

  static Future<void> setErr() async {
    hasErr = true;
    set('error');
  }

  static Future<void> revertErr() async {
    hasErr = false;
    String icon = currentIcon;
    if (currentIcon.isEmpty) icon = 'grey';
    set(icon);
  }
}

Future<String> getVersion() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
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
  return platform.invokeMethod('UUID');
}

bool shouldUseFirebase() {
  return Platform.isIOS;
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
