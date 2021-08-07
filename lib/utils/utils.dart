import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel platform = MethodChannel('max.me.uk/notifications');
const String refKey = 'ref';
const String messageKey = 'msg';
final EmojiParser eParser = EmojiParser();

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
  await dotenv.load();
  if (isTest()) return true;
  return dotenv.isEveryDefined(
      <String>['HOST', 'KEY_STORE', 'TLS', 'SERVER_KEY', 'DEV']);
}

String get wsEndpoint {
  String protocol = 'ws://';
  if (dotenv.env['TLS'] == 'true') {
    protocol = 'wss://';
  }
  return '$protocol${dotenv.env['HOST']}/ws';
}

String get codeEndpoint {
  return '$httpEndpoint/code';
}

String get versionEndpoint {
  String develop = '';
  if (dotenv.env['DEV'] == 'true') {
    develop = '?develop';
  }
  return '$httpEndpoint/version$develop';
}

String get httpEndpoint {
  String protocol = 'http://';
  if (dotenv.env['TLS'] == 'true') {
    protocol = 'https://';
  }
  return '$protocol${dotenv.env['HOST']}';
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
  return platform.invokeMethod('UUID');
}

bool get shouldUseFirebase {
  return Platform.isIOS || Platform.isAndroid;
}

class L {
  static void d(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static void i(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static void w(String msg) {
    // ignore: avoid_print
    print(msg);
  }

  static void e(String msg) {
    // ignore: avoid_print
    print(msg);
  }
}

bool shouldPinWindow(SharedPreferences sp) {
  try {
    return sp.getBool('pin-window') || false;
  } catch (_) {
    return false;
  }
}

void copyText(String text, BuildContext context) {
  Clipboard.setData(ClipboardData(text: text));
  Toast.show('📋 $text', context, gravity: Toast.BOTTOM);
}

bool hasTextOverflow(String text, TextStyle style,
    {double maxWidth = double.infinity, int maxLines = 1}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  )..layout(minWidth: 0, maxWidth: maxWidth - 1);
  // not really sure why I have to -1
  return textPainter.didExceedMaxLines;
}

String getEclipsedText(String text, TextStyle style,
    {double maxWidth = double.infinity, int maxLines = 1}) {
  for (int i = 5; i < text.length; i++) {
    final String eclipsedText = '${text.substring(0, i)}...';
    if (hasTextOverflow(eclipsedText, style,
        maxWidth: maxWidth, maxLines: maxLines)) {
      return '${text.substring(0, i - 1)}...';
    }
  }
  throw Exception('width too short to eclipse');
}

double windowWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
