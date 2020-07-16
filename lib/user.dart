import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

final storage = new FlutterSecureStorage();

const RequestNewUserCode = 551;

class User {
  String UUID;
  String credentialKey;
  String credentials;
  String flutterToken;

  User(this.UUID, this.credentialKey, this.credentials, {this.flutterToken});
}

Future<User> fetchUser() async {
  // init secure storage

  String flutterToken;
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
    // initiate firebase
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    if (await storage.read(key: "firebase-token") == null) {
      print("creating new firebase token");
      _firebaseMessaging.getToken().then((token) async {
        flutterToken = token;
        print(flutterToken);
        await storage.write(key: "firebase-token", value: token);
      });
    }
  }

  String UUID = await storage.read(key: "UUID");
  String credentials = await storage.read(key: "credentials");
  String credentialKey = await storage.read(key: "credential_key");
  var user =
      new User(UUID, credentialKey, credentials, flutterToken: flutterToken);

  if (user.UUID == null ||
      user.credentialKey == null ||
      user.credentials == null) {
    // CREATE NEW USER
    var alreadyHadCredentials = false;
    if (user.UUID != null ||
        user.credentialKey != null ||
        user.credentials != null) {
      alreadyHadCredentials = true;
    }

    // Create new credentials as the user does not have any. it is completely
    // vital that this is successful so need to retry until it is.
    while (true) {
      user = await RequestNewUser(user);
      if (user != null) {
        break;
      }
      sleep(Duration(seconds: 2));
      print("Retrying request for a new code");
    }

    if (alreadyHadCredentials) {
      // TODO return message to user to tell them that there credentials have been replaced
    }
  }
  return user;
}

Future<User> RequestNewUser(User user) {
  var data = {"UUID": Uuid().v4()};
  if (user.credentialKey != null) {
    data["current_credential_key"] = user.credentialKey;
  }
  if (user.credentials != null) {
    data["current_credentials"] = user.credentials;
  }
  return _newUserReq(user, data);
}

Future<User> _newUserReq(User user, Map<String, dynamic> data) async {
  print("creating brand new user");
  d.Dio dio = new d.Dio();
  var response = await dio.post(DotEnv().env['HOST'] + "code",
      data: data,
      options: d.Options(headers: {
        "Sec-Key": DotEnv().env["SERVER_KEY"],
      }, contentType: d.Headers.formUrlEncodedContentType));

  if (response.statusCode != HttpStatus.ok) {
    print("Major problem creating new code: $response");
    return null;
  }

  // decode response
  Map credentialsMap;
  try {
    credentialsMap = jsonDecode(response.data);
  } catch (e) {
    print('Problem decoding new code message: $e - ' + response.data);
    return null;
  }

  user.UUID = data["UUID"];
  user.credentialKey = credentialsMap["credential_key"];
  user.credentials = credentialsMap["credentials"];

  await storage.write(key: "UUID", value: user.UUID);
  await storage.write(key: "UUIDKey", value: user.credentialKey);
  await storage.write(key: "credential_key", value: user.credentials);

  return user;
}
