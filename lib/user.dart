import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notifi/utils/local_notifications.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/utils/utils.dart';
import 'package:notifi/ws.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class User with ChangeNotifier {
  User(this._notifications, this._pushNotifications) {
    _user = UserStruct();
    setNotifications(_notifications);
    if (!isTest()) {
      _loadUser();
    }
  }

  UserStruct _user;
  bool _hasError = false;
  String flutterToken;

  Notifications _notifications;

  IOWebSocketChannel _ws;
  final FlutterLocalNotificationsPlugin _pushNotifications;

  // ignore: use_setters_to_change_properties
  void setNotifications(Notifications _notifications) {
    this._notifications = _notifications;
  }

  String getCredentials() {
    return _user.credentials;
  }

  Future<void> _loadUser() async {
    _user = UserStruct();
    final bool hadUser = await _user.load();

    // create new credentials if any are missing
    while (_user.isNull()) {
      // Create new credentials as the user does not have any.
      await setNewUser();

      setErr(_user.isNull());
      if (_user.isNull()) {
        L.w('Attempting to create user again...');
        await Future<dynamic>.delayed(const Duration(seconds: 5));
      }
    }

    if (hadUser) {
      await _initWSS();
    }
  }

  Future<bool> setNewUser() async {
    final Map<String, dynamic> postData = <String, String>{
      'UUID': await getDeviceUUID()
    };

    if (!_user.isNull()) {
      postData['current_credential_key'] = _user.credentialKey;
      postData['current_credentials'] = _user.credentials;
      if (shouldUseFirebase) {
        postData['firebase_token'] =
            await FirebaseMessaging.instance.getToken();
      }
      L.w('Replacing credentials: ${_user.credentials}');
    }

    final UserStruct newUser = await _newUserReq(postData);
    if (!newUser.isNull()) {
      // store user credentials
      if (await newUser.store()) {
        _user = newUser;

        await _initWSS();

        notifyListeners();
      }
    }
    return !newUser.isNull();
  }

  ////////
  // ws //
  ////////
  Future<void> _initWSS() async {
    if (_ws != null) {
      L.i('Closing already open WS...');
      await _ws.sink.close(status.normalClosure, 'new code!');
    }
    _ws = await connectToWS(_user, _handleMessage, setErr);
  }

  Future<UserStruct> _newUserReq(Map<String, dynamic> data) async {
    L.i('Creating new credentials...');
    final d.Dio dio = d.Dio();
    Response<dynamic> response;
    try {
      response = await dio.post(env['CODE_ENDPOINT'],
          data: data,
          options: d.Options(headers: <String, dynamic>{
            'Sec-Key': env['SERVER_KEY'],
          }, contentType: d.Headers.formUrlEncodedContentType));
    } on DioError catch (e, _) {
      // ignore: always_specify_types
      final d.Response resp = e.response;
      L.e('Problem fetching user code: ${resp.statusCode}');
      L.e(resp.statusMessage);
      return UserStruct();
    }

    if (response.statusCode != HttpStatus.ok) {
      L.e('Problem fetching new code from server: $response');
      return UserStruct();
    }

    // decode response
    Map<String, dynamic> credentialsMap;
    try {
      credentialsMap =
          json.decode(response.data as String) as Map<String, dynamic>;
    } catch (e) {
      L.e('Problem decoding new code from server: $e - ${response.data}');
      return UserStruct();
    }

    return UserStruct(
      uuid: data['UUID'],
      credentials: credentialsMap['credentials'] as String,
      credentialKey: credentialsMap['credential_key'] as String,
    );
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
    bool hasNotification = false;
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
          // send push notification
          sendLocalNotification(_pushNotifications, id, notification);
          hasNotification = true;
        }
        msgUUIDs.add(notification.uuid);
      }
    }

    if (hasNotification) {
      // animate menu bar icon
      invokeMacMethod('animate');
    }
    return msgUUIDs;
  }

  ///////////
  // error //
  ///////////
  bool hasError() {
    return _hasError;
  }

  bool _tmpErr;

  // ignore: avoid_positional_boolean_parameters
  void setErr(bool hasErr) {
    // wait for 1 second to make sure hasErr hasn't changed.
    // To prevent from stuttering.
    _tmpErr = hasErr;
    Future<dynamic>.delayed(const Duration(seconds: 1), () {
      if (_tmpErr == hasErr) {
        if (_tmpErr) {
          MenuBarIcon.setErr();
        } else {
          MenuBarIcon.revertErr();
        }
        _hasError = _tmpErr;
        notifyListeners();
      }
    });
  }
}

class UserStruct {
  UserStruct({this.uuid, this.credentialKey, this.credentials}) {
    _storage = const FlutterSecureStorage();
    if (!isTest()) _key = 'notifi-${env['KEY_STORE']}';
  }

  FlutterSecureStorage _storage;
  String _key;

  String uuid;
  String credentialKey;
  String credentials;

  bool isNull() {
    return uuid == null || credentialKey == null || credentials == null;
  }

  Future<bool> store() async {
    try {
      await _storage.write(key: _key, value: _toJson());
    } catch (e) {
      L.e(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> load() async {
    String userJsonString;
    try {
      userJsonString = await _storage.read(key: _key);
    } catch (e) {
      L.e(e.toString());
      return false;
    }

    try {
      final Map<String, dynamic> userJson =
          jsonDecode(userJsonString) as Map<String, dynamic>;

      uuid = userJson['UUID'];
      credentials = userJson['credentials'];
      credentialKey = userJson['credentialKey'];
    } catch (error) {
      L.e(error.toString());
      return false;
    }
    return true;
  }

  String _toJson() {
    if (isNull()) throw 'Cannot encode unset user';
    return jsonEncode(<String, String>{
      'UUID': uuid,
      'credentials': credentials,
      'credentialKey': credentialKey,
    });
  }
}
