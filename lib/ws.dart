import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifi/local-notifications.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/user.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:web_socket_channel/io.dart';

// values defined by backend
const refKey = "ref";
const messageKey = "msg";

Future<IOWebSocketChannel> initWS(
    User user,
    FlutterLocalNotificationsPlugin localNotification,
    NotificationTable nt) async {
  if (user.isNull()) {
    await new Future.delayed(Duration(seconds: 3));
    return await initWS(user, localNotification, nt);
  }

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var headers = {
    "Sec-Key": DotEnv().env["SERVER_KEY"],
    "Credentials": user.credentials,
    "Uuid": user.UUID,
    "Key": user.credentialKey,
    "Version": packageInfo.version,
  };

  var ws = IOWebSocketChannel.connect(DotEnv().env['WS_HOST'],
      headers: headers, pingInterval: Duration(seconds: 15));

  print("ws open");
  ws.stream.listen((msg) {
    // decode incoming ws message
    Map<String, dynamic> mapWS;
    try {
      mapWS = json.decode(msg);
    } catch (e) {
      print("ignoring un-parsable incoming ws message from server: $msg");
    }

    if (mapWS != null && mapWS[refKey] != null && mapWS[messageKey] != null) {
      // send acknowledgement back to server
      ws.sink.add(sprintf('{"%s": "%s"}', [refKey, mapWS[refKey]]));

      // decode base64 encoded message json to string
      List<dynamic> jsonMessage;
      try {
        jsonMessage =
            json.decode(utf8.decode(base64Url.decode(mapWS[messageKey])));
      } catch (e) {
        print("ignoring un-parsable ws message: $msg\n$e");
      } finally {
        // handle message
        _handleWSMessage(localNotification, nt, jsonMessage);
      }
    } else {
      print("invalid json message from server: $msg");
    }
  }, onError: (error) {
    print(error);
  }, onDone: () async {
    print("ws closed");
    await new Future.delayed(Duration(seconds: 3));
    return await initWS(user, localNotification, nt);
  });
  return ws;
}

Future _handleWSMessage(FlutterLocalNotificationsPlugin localNotification,
    NotificationTable notificationTable, List<dynamic> messages) async {
  for (var i = 0; i < messages.length; i++) {
    var notification = NotificationUI.fromJson(messages[i]);

    // store notification
    int id = await notificationTable.add(notification);

    // send local notification
    sendLocalNotification(localNotification, id, notification);
  }
}
