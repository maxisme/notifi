import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:f_logs/model/flog/log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notifi/pallete.dart';
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

Future<String> getVersionFromPubSpec() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
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

  static Future<ListView> logListView() async {
    final List<Log> logs = await FLog.getAllLogs();

    final List<Container> rows = <Container>[];
    for (int i = logs.length - 1; i >= logs.length - 100; i--) {
      final Log log = logs[i];
      rows.add(Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: log.logLevel
                      .toString()
                      .replaceAll('LogLevel.', '')
                      .substring(0, 4),
                  style: const TextStyle(
                      color: MyColour.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Inconsolata'),
                ),
                TextSpan(
                  text: ' ~ ${log.timestamp}\n',
                  style: const TextStyle(
                      color: MyColour.grey,
                      fontWeight: FontWeight.w100,
                      fontSize: 12,
                      fontFamily: 'Inconsolata'),
                ),
                TextSpan(
                  text: log.text,
                  style: const TextStyle(
                      color: MyColour.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Inconsolata'),
                ),
              ])),
            ),
          ],
        ),
      ));
    }
    return ListView(children: rows);
  }
}

Future<void> showAlert(BuildContext context, String title, String description,
    {int duration, int gravity, VoidCallback onOkPressed}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: const Icon(
              Akaricons.triangleAlert,
              color: MyColour.red,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.left,
          )
        ]),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: MyColour.grey),
            ),
          ),
          TextButton(
              onPressed: onOkPressed,
              child: const Text(
                'Ok',
                style: TextStyle(color: MyColour.black),
              )),
        ],
      );
    },
  );
}

class Akaricons {
  Akaricons._();

  static const String _kFontFam = 'Akaricons';

  static const IconData check = IconData(0xe800, fontFamily: _kFontFam);
  static const IconData copy = IconData(0xe801, fontFamily: _kFontFam);
  static const IconData enlarge = IconData(0xe802, fontFamily: _kFontFam);
  static const IconData link = IconData(0xe803, fontFamily: _kFontFam);
  static const IconData reduce = IconData(0xe804, fontFamily: _kFontFam);
  static const IconData trash = IconData(0xe805, fontFamily: _kFontFam);
  static const IconData chevronLeft = IconData(0xe806, fontFamily: _kFontFam);
  static const IconData chevronRight = IconData(0xe807, fontFamily: _kFontFam);
  static const IconData cloudDownload = IconData(0xe808, fontFamily: _kFontFam);
  static const IconData cross = IconData(0xe809, fontFamily: _kFontFam);
  static const IconData gear = IconData(0xe80a, fontFamily: _kFontFam);
  static const IconData arrowClockwise =
      IconData(0xe81d, fontFamily: _kFontFam);
  static const IconData clipboard = IconData(0xe81e, fontFamily: _kFontFam);
  static const IconData file = IconData(0xe81f, fontFamily: _kFontFam);
  static const IconData info = IconData(0xe820, fontFamily: _kFontFam);
  static const IconData question = IconData(0xe821, fontFamily: _kFontFam);
  static const IconData signOut = IconData(0xe822, fontFamily: _kFontFam);
  static const IconData triangleAlert = IconData(0xe823, fontFamily: _kFontFam);
  static const IconData circleAlert = IconData(0xe824, fontFamily: _kFontFam);
  static const IconData person = IconData(0xe825, fontFamily: _kFontFam);
  static const IconData doubleCheck = IconData(0xe814, fontFamily: _kFontFam);
}
