import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/user.dart';
import 'package:package_info/package_info.dart';
import 'package:web_socket_channel/io.dart';

import 'local-notifications.dart';
import 'notifications/notification.dart';

const platform = const MethodChannel('max.me.uk/notifications');
const refKey = "ref";
const messageKey = "msg";


Future<void> invokeMethod(method) async {
  try {
    await platform.invokeMethod(method);
  } on PlatformException catch (e) {
    print("Failed to invoke method ($method): '${e.message}'.");
  }
}

Future<String> getVersionFromPubSpec() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}

var ws;
Future<IOWebSocketChannel> connectToWs(User user,
    FlutterLocalNotificationsPlugin localNotification,
    HomeScreen homeScreen) async {
  if (user.isNull()) {
    await new Future.delayed(Duration(seconds: 3));
    return await connectToWs(user, localNotification, homeScreen);
  }

  var headers = {
    "Sec-Key": env["SERVER_KEY"],
    "Credentials": user.credentials.value,
    "Uuid": user.UUID,
    "Key": user.credentialKey,
    "Version": await getVersionFromPubSpec(),
  };

  if (ws != null){
    ws.sink.close();
    ws = null;
  }

  ws = IOWebSocketChannel.connect(env['WS_ENDPOINT'], headers: headers, pingInterval: Duration(seconds: 5));

  print("Connecting to Websocket...");
  homeScreen.setError(false);

  ws.stream.listen((msg) async {
    // decode incoming ws message
    List<dynamic> notifications;
    try {
      notifications = json.decode(msg);
    } catch (e) {
      print("ignoring un-parsable incoming message from server: $msg: $e");
      homeScreen.setError(true);
    }

    // parse notifications from websocket message
    var UUIDs = "";
    for (var i = 0; i < notifications.length; i++) {
      Map<String, dynamic> jsonMessage;
      var n = notifications[i];
      try {
        jsonMessage = new Map<String, dynamic>.from(n);
      } catch (e) {
        print("ignoring un-parsable ws message: $msg\n$e\n$n");
      }
      if (jsonMessage != null) {
        var notification = NotificationUI.fromJson(jsonMessage);

        // store notification
        int id = await homeScreen.add(notification);

        // send local notification
        if (id != -1) {
          sendLocalNotification(localNotification, id, notification);
          UUIDs += "," + notification.UUID;
        }
      }
    }
    if (UUIDs.length > 0){
      print(UUIDs);
      ws.sink.add(UUIDs);
    }
  }, onError: (error) {
    print(error);
    homeScreen.setError(true);
  }, onDone: () async {
    print("ws closed");
    homeScreen.setError(true);
    await Future.delayed(Duration(seconds: 3));
    return await connectToWs(user, localNotification, homeScreen);
  });

  return ws;
}