import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel platform = MethodChannel('max.me.uk/notifications');
const String refKey = 'ref';
const String messageKey = 'msg';

bool isTest() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}

Future<dynamic> invokeMacMethod(String method, [dynamic arguments]) async {
  if (Platform.isMacOS && !isTest()) {
    try {
      return await platform.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      L.e("Failed to invoke method ($method): '${e.message}'.");
    }
  }
}

String currentIcon = '';
bool hasErr = false;

class MenuBarIcon {
  static Future<void> set(String icon) async {
    if (!hasErr) {
      await invokeMacMethod('${icon}_menu_icon');
    }
    if (icon != 'error') currentIcon = icon;
  }

  static Future<void> setErr() async {
    await set('error');
    hasErr = true;
  }

  static Future<void> revertErr() async {
    hasErr = false;
    String icon = currentIcon;
    if (currentIcon.isEmpty) icon = 'grey';
    await set(icon);
  }
}

Future<bool> loadDotEnv() async {
  await dot_env.load();
  if (isTest()) return true;
  return dot_env.isEveryDefined(
      <String>['HOST', 'KEY_STORE', 'TLS', 'SERVER_KEY', 'DEV']);
}

String get wsEndpoint {
  String protocol = 'ws://';
  if (dot_env.env['TLS'] == 'true') {
    protocol = 'wss://';
  }
  return '$protocol${dot_env.env['HOST']}/ws';
}

String get codeEndpoint {
  String protocol = 'http://';
  if (dot_env.env['TLS'] == 'true') {
    protocol = 'https://';
  }
  return '$protocol${dot_env.env['HOST']}/code';
}

String get versionEndpoint {
  String protocol = 'http://';
  if (dot_env.env['TLS'] == 'true') {
    protocol = 'https://';
  }
  String develop = '';
  if (dot_env.env['DEV'] == 'true') {
    develop = '?develop';
  }
  return '$protocol${dot_env.env['HOST']}/version$develop';
}

Future<void> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false);
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

bool get shouldUseFirebase {
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
