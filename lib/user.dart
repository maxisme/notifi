import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notifi/local-notifications.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'notifications/notification.dart';

final storage = new UserStore();

const RequestNewUserCode = 551;

class User with ChangeNotifier {
  String UUID;
  String credentialKey;
  String credentials;
  bool _hasError = false;
  String flutterToken;

  Notifications _notifications;

  IOWebSocketChannel _ws;
  Future<FlutterLocalNotificationsPlugin> _pushNotifications;

  User(this._notifications) {
    setNotifications(_notifications);
    _pushNotifications = initPushNotifications();
    _createUser();
  }

  void setNotifications(Notifications _notifications) {
    this._notifications = _notifications;
  }

  bool isNull() {
    return UUID == null || credentialKey == null || credentials == null;
  }

  Future<bool> _createUser() async {
    await DotEnv.load(fileName: ".env");

    // attempt to get user if exists
    var gotUser = await storage.getUser(this);

    // create new credentials if any are missing
    while (!gotUser) {
      var alreadyHadCredentials =
          (UUID != null || credentialKey != null || credentials != null);

      // Create new credentials as the user does not have any.
      gotUser = await RequestNewUser();

      if (gotUser) {
        if (alreadyHadCredentials && gotUser) {
          // TODO return message to user to tell them that there credentials have been replaced
          print("replaced your credentials...");
        }
      } else {
        print("attempting to create user again...");
        await Future.delayed(Duration(seconds: 5));
      }
    }

    _ws = await _initWSS();
  }

  Future<bool> RequestNewUser() async {
    var data = {"UUID": Uuid().v4()}; // generate UUID for user
    if (!isNull()) {
      data["current_credential_key"] = credentialKey;
      data["current_credentials"] = credentials;
    }
    var gotUser = await _newUserReq(data);
    if (gotUser == true && _ws != null) {
      _ws.sink.close(status.normalClosure, "new code!");
    }
    return gotUser;
  }

  ////////
  // ws //
  ////////
  _initWSS() async {
    if (_ws != null) {
      print("closing...");
      _ws.sink.close();
      _ws = null;
    }
    _ws = await _connectToWS();
  }

  Future<IOWebSocketChannel> _connectToWS() async {
    if (isNull()) {
      print("user not ready...");
      await Future.delayed(Duration(seconds: 2));
      return await _connectToWS();
    }
    var headers = {
      "Sec-Key": env["SERVER_KEY"],
      "Credentials": credentials,
      "Uuid": UUID,
      "Key": credentialKey,
      "Version": await getVersionFromPubSpec(),
    };

    print("connecting...");
    setError(false);
    var ws = IOWebSocketChannel.connect(env['WS_ENDPOINT'],
        headers: headers, pingInterval: Duration(seconds: 5));

    ws.stream.listen((streamData) async {
      var msg = await _handleMessage(streamData);
      if (msg != null) {
        ws.sink.add(jsonEncode(msg));
      }
    }, onError: (e) async {
      print('WS error: $e');
      setError(true);
    }, onDone: () async {
      print("ws connection closed");
      await Future.delayed(Duration(seconds: 5));
      setError(true);
      return await _connectToWS();
    });

    return ws;
  }

  Future<bool> _newUserReq(Map<String, dynamic> data) async {
    print("creating new user...");
    d.Dio dio = new d.Dio();
    var response;
    try {
      response = await dio.post(env['CODE_ENDPOINT'],
          data: data,
          options: d.Options(headers: {
            "Sec-Key": env["SERVER_KEY"],
          }, contentType: d.Headers.formUrlEncodedContentType));
    } catch (e) {
      print('Problem fetching user code: $e');
      return false;
    }

    if (response.statusCode != HttpStatus.ok) {
      print("Problem fetching new code from server: $response");
      return false;
    }

    // decode response
    Map credentialsMap;
    try {
      credentialsMap = jsonDecode(response.data);
    } catch (e) {
      print('Problem decoding new code from server: $e - ' + response.data);
      return false;
    }

    // set variables
    UUID = data["UUID"];
    credentialKey = credentialsMap["credential_key"];
    credentials = credentialsMap["credentials"];

    // store user credentials
    await storage.writeUser(this);
    return true;
  }

  _handleMessage(msg) async {
    // json decode incoming ws message
    List<dynamic> notifications = [];
    try {
      notifications = json.decode(msg);
    } catch (e) {
      print("ignoring un-parsable incoming message from server: $msg: $e");
      return;
    }

    // parse notifications from websocket message
    var msgUUIDs = [];
    for (var i = 0; i < notifications.length; i++) {
      Map<String, dynamic> jsonMessage;
      try {
        jsonMessage = new Map<String, dynamic>.from(notifications[i]);
      } catch (e) {
        print("ignoring un-parsable ws message: $msg: $e");
        return;
      }

      if (jsonMessage != null) {
        var notification = NotificationUI.fromJson(jsonMessage);

        // store notification
        int id = await _notifications.add(notification);

        if (id != -1) {
          // send local notification
          sendLocalNotification(await _pushNotifications, id, notification);
          if (Platform.isMacOS) invokeMethod("animate");
        }
        msgUUIDs.add(notification.UUID);
      }
    }
    if (msgUUIDs.length > 0) {
      return msgUUIDs;
    }
  }

  ///////////
  // error //
  ///////////
  hasError() {
    return _hasError;
  }

  var err;
  setError(bool err) {
    this.err = err;
    Future.delayed(const Duration(seconds: 1), () {
      if (this.err == err) {
        if (err) {
          invokeMethod("error_icon");
        }
        this._hasError = err;
        notifyListeners();
      }
    });
  }
}

class UserStore {
  final storage = new FlutterSecureStorage();
  static const key = "user";
  static const linuxFilePath = "user-store.json";

  Future<bool> getUser(User user) async {
    var userJsonString;
    try {
      userJsonString = await storage.read(key: key);
    } on MissingPluginException catch (_) {
      // read json from file
      var file = await _getLinuxFile();
      userJsonString = await file.readAsString();
    }

    try {
      var userJson = jsonDecode(userJsonString);
      user.UUID = userJson["UUID"];
      user.credentialKey = userJson["credentialKey"];
      user.credentials = userJson["credentials"];
      user.flutterToken = userJson["flutterToken"];
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  Future writeUser(User user) async {
    String jsonData = jsonEncode({
      'UUID': user.UUID,
      'credentialKey': user.credentialKey,
      'credentials': user.credentials,
    });
    try {
      await storage.write(key: key, value: jsonData);
    } on MissingPluginException catch (e) {
      print("unable to store in keychain - storing in file $e");
      // write to file instead of keychain
      var file = await _getLinuxFile();
      file.writeAsString(jsonData);
    } catch (e) {
      print("unable to store in keychain $e");
    }
  }

  Future<File> _getLinuxFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/.notifi/' + linuxFilePath;
    File file = File(savePath);
    file.create(recursive: true);
    return file;
  }
}
