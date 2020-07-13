import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

const RequestNewUserCode = 551;

class User {
  final String UUID;
  final String UUIDKey;
  final String credentials;

  const User(this.UUID, this.UUIDKey, this.credentials);
}

Future<User> fetchUser() async {
  final storage = new FlutterSecureStorage();

  String UUID = await storage.read(key: "UUID");
  String UUIDKey = await storage.read(key: "UUIDKey");
  String credentials = await storage.read(key: "credentials");
  var user = new User(UUID, UUIDKey, credentials);

  if (user.UUID == null || user.UUIDKey == null || user.credentials == null) {
    // CREATE NEW USER
    var alreadyHadCredentials = false;
    if (user.UUID != null || user.UUIDKey != null || user.credentials != null) {
      alreadyHadCredentials = true;
    }

    // Create new credentials as the user does not have any. it is completely
    // vital that this is successful so need to retry until it is.
    while (true) {
      user = await requestNewUser(user);
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

Future<User> requestNewUser(User user) {
  var data = {"UUID": Uuid().v4()};
  if (user.UUIDKey != null) {
    data["current_UUIDKey"] = user.UUIDKey;
  }
  if (user.credentials != null) {
    data["current_credentials"] = user.credentials;
  }
  return _newUserReq(data);
}

Future<User> _newUserReq(Map<String, dynamic> data) async {
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

  var user = new User(
      data["UUID"], credentialsMap["UUIDKey"], credentialsMap["credentials"]);

  var storage = FlutterSecureStorage();
  await storage.write(key: "UUID", value: user.UUID);
  await storage.write(key: "UUIDKey", value: user.UUIDKey);
  await storage.write(key: "credentials", value: user.credentials);

  return user;
}
