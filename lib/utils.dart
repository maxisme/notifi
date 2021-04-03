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

Future<void> invokeMacMethod(String method) async {
  if (Platform.isMacOS && !isTest()) {
    try {
      await platform.invokeMethod(method);
    } on PlatformException catch (e) {
      L.e("Failed to invoke method ($method): '${e.message}'.");
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
    L.w("Can't open: $url");
  }
}

void showToast(String msg, BuildContext context, {int duration, int gravity}) {
  Toast.show(msg, context, duration: duration, gravity: gravity);
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
        title: Text(title),
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
