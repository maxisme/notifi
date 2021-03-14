import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifi/local-notifications.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/screens/home.dart';
import 'package:notifi/user.dart';
import 'package:web_socket_channel/io.dart';

// values defined by backend
const refKey = "ref";
const messageKey = "msg";

Future<IOWebSocketChannel> connectToWs(
    User user,
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

  var ws = IOWebSocketChannel.connect("wss://" + env['HOST'] + "/ws",
      headers: headers, pingInterval: Duration(seconds: 5));

  print("Connecting to Websocket...");
  homeScreen.setError(false);

  ws.stream.listen((msg) async {
    // decode incoming ws message
    List<dynamic> notifications;
    try {
      notifications = json.decode(msg);
    } catch (e) {
      print(e);
      print("ignoring un-parsable incoming WS message from server: $msg");
      homeScreen.setError(true);
    }

    // parse notifications from websocket message
    for (var i = 0; i < notifications.length; i++) {
      Map<String, dynamic> jsonMessage;
      var n = notifications[i];
      try {
        jsonMessage = new Map<String, dynamic>.from(n);
      } catch (e) {
        print("ignoring un-parsable ws message: $msg\n$e\n$n");
      }
      if (jsonMessage != null) {
        try {
          var notification = NotificationUI.fromJson(jsonMessage);

          // store notification
          int id = await homeScreen.add(notification);

          // send local notification
          sendLocalNotification(localNotification, id, notification);
        } catch (e) {
          print("Problem storing notification: $e");
        }
      }
    }
  }, onError: (error) {
    print(error);
    homeScreen.setError(true);
  }, onDone: () async {
    print("ws closed");
    homeScreen.setError(true);
    await new Future.delayed(Duration(seconds: 3));
    return connectToWs(user, localNotification, homeScreen);
  });

  return ws;
}

Future<String> getVersionFromPubSpec() async {
  // TODO fix
  // File f = new File("./pubspec.yaml");
  // var content = await f.readAsString();
  // Map yaml = loadYaml(content);
  // return yaml['version'];
  return "1.0.0";
}
