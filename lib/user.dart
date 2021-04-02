import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notifi/local_notifications.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

final UserStore storage = UserStore();

const int requestNewUserCode = 551;

class User with ChangeNotifier {
  User(this._notifications, this._pushNotifications) {
    setNotifications(_notifications);
    if (!isTest()) {
      _createUser();
    }
  }

  String uuid;
  String credentialKey;
  String credentials = '';
  bool _hasError = false;
  String flutterToken;

  Notifications _notifications;

  IOWebSocketChannel _ws;
  final FlutterLocalNotificationsPlugin _pushNotifications;

  // ignore: use_setters_to_change_properties
  void setNotifications(Notifications _notifications) {
    this._notifications = _notifications;
  }

  bool isNull() {
    return uuid == null || credentialKey == null || credentials == null;
  }

  Future<void> _createUser() async {
    await dot_env.load();

    // attempt to get user if exists
    bool gotUser = await storage.getUser(this);

    // create new credentials if any are missing
    while (!gotUser) {
      final bool alreadyHadCredentials =
          uuid != null || credentialKey != null || credentials != null;

      // Create new credentials as the user does not have any.
      gotUser = await requestNewUser();

      if (gotUser) {
        setError(hasErr: false);
        if (alreadyHadCredentials && gotUser) {
          // TODO return message to user to tell them
          // that there credentials have been replaced
          L.e('Replaced your credentials...');
        }
      } else {
        setError(hasErr: true);
        L.w('Attempting to create user again...');
        await Future<dynamic>.delayed(const Duration(seconds: 5));
      }
    }

    await _initWSS();
  }

  Future<bool> requestNewUser() async {
    // generate UUID for user
    final Map<String, dynamic> data = <String, String>{'UUID': Uuid().v4()};
    if (!isNull()) {
      data['current_credential_key'] = credentialKey;
      data['current_credentials'] = credentials;
    }
    final bool gotUser = await _newUserReq(data);
    if (gotUser && _ws != null) {
      L.i('Reconnecting to ws...');
      _ws.sink.close(status.normalClosure, 'new code!');
    }
    notifyListeners();
    return gotUser;
  }

  ////////
  // ws //
  ////////
  Future<void> _initWSS() async {
    if (_ws != null) {
      L.i('Closing already open WS...');
      _ws.sink.close();
      _ws = null;
    }
    _ws = await _connectToWS();
  }

  Future<IOWebSocketChannel> _connectToWS() async {
    final Map<String, dynamic> headers = <String, dynamic>{
      'Sec-Key': env['SERVER_KEY'],
      'Credentials': credentials,
      'Uuid': uuid,
      'Key': credentialKey,
      'Version': await getVersionFromPubSpec(),
    };

    L.i('Connecting to WS...');
    setError(hasErr: false);
    final IOWebSocketChannel ws = IOWebSocketChannel.connect(env['WS_ENDPOINT'],
        headers: headers, pingInterval: const Duration(seconds: 3));

    bool wsError = false;
    ws.stream.listen((dynamic streamData) async {
      wsError = false;
      final List<String> msgUUIDs = await _handleMessage(streamData);
      if (msgUUIDs != null) {
        ws.sink.add(jsonEncode(msgUUIDs));
      }
      // ignore: always_specify_types
    }, onError: (e) async {
      wsError = true;
      L.w('Problem with WS: $e');
    }, onDone: () async {
      L.i('WS connection closed.');
      if (wsError) {
        setError(hasErr: true);
        await Future<dynamic>.delayed(const Duration(seconds: 5));
      }
      await _initWSS();
    });

    return ws;
  }

  Future<bool> _newUserReq(Map<String, dynamic> data) async {
    L.i('Creating new credentials...');
    final d.Dio dio = d.Dio();
    Response<dynamic> response;
    try {
      response = await dio.post(env['CODE_ENDPOINT'],
          data: data,
          options: d.Options(headers: <String, dynamic>{
            'Sec-Key': env['SERVER_KEY'],
          }, contentType: d.Headers.formUrlEncodedContentType));
    } catch (e) {
      L.e('Problem fetching user code: $e');
      return false;
    }

    if (response.statusCode != HttpStatus.ok) {
      L.e('Problem fetching new code from server: $response');
      return false;
    }

    // decode response
    Map<String, dynamic> credentialsMap;
    try {
      credentialsMap =
          json.decode(response.data as String) as Map<String, dynamic>;
    } catch (e) {
      L.e('Problem decoding new code from server: $e - ${response.data}');
      return false;
    }

    // set variables
    uuid = data['UUID'];
    credentialKey = credentialsMap['credential_key'] as String;
    credentials = credentialsMap['credentials'] as String;

    // store user credentials
    await storage.writeUser(this);
    notifyListeners();
    return true;
  }

  Future<List<String>> _handleMessage(dynamic msg) async {
    // json decode incoming ws message
    List<dynamic> notifications = <dynamic>[];
    try {
      notifications = json.decode(msg as String) as List<dynamic>;
    } catch (e) {
      L.e('Ignoring un-parsable incoming message from server: $msg: $e');
      return <String>[];
    }

    // parse notifications from websocket message
    final List<String> msgUUIDs = <String>[];
    for (int i = 0; i < notifications.length; i++) {
      Map<String, dynamic> jsonMessage;
      try {
        jsonMessage = Map<String, dynamic>.from(notifications[i]);
      } catch (e) {
        L.e('Ignoring un-parsable WS message: $msg: $e');
        return <String>[];
      }

      if (jsonMessage != null) {
        final NotificationUI notification =
            NotificationUI.fromJson(jsonMessage);

        // store notification
        final int id = await _notifications.add(notification);

        if (id != -1) {
          // send local notification
          sendLocalNotification(_pushNotifications, id, notification);
          invokeMacMethod('animate');
        }
        msgUUIDs.add(notification.uuid);
      }
    }
    return msgUUIDs;
  }

  ///////////
  // error //
  ///////////
  bool hasError() {
    return _hasError;
  }

  bool err;

  void setError({bool hasErr}) {
    // wait for 1 second to make sure hasErr hasn't changed to prevent
    // stuttering.
    err = hasErr;
    Future<dynamic>.delayed(const Duration(seconds: 1), () {
      if (err == hasErr) {
        if (err) {
          invokeMacMethod('error_icon');
        }
        _hasError = err;
        notifyListeners();
      }
    });
  }
}

class UserStore {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  static const String key = 'user';
  static const String linuxFilePath = 'user-store.json';

  Future<bool> getUser(User user) async {
    String userJsonString;
    try {
      userJsonString = await storage.read(key: key);
    } catch (e) {
      L.f(e);
    }

    try {
      final Map<String, dynamic> userJson =
          jsonDecode(userJsonString) as Map<String, dynamic>;
      user.uuid = userJson['UUID'];
      user.credentialKey = userJson['credentialKey'];
      user.credentials = userJson['credentials'];
      user.flutterToken = userJson['flutterToken'];
    } catch (error) {
      L.f(error);
      return false;
    }
    return true;
  }

  Future<void> writeUser(User user) async {
    final String jsonData = jsonEncode(<String, String>{
      'UUID': user.uuid,
      'credentialKey': user.credentialKey,
      'credentials': user.credentials,
    });
    try {
      await storage.write(key: key, value: jsonData);
    } catch (e) {
      L.f(e);
    }
  }
}
