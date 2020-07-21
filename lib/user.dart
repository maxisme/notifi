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
  Future _doneFuture;
  String UUID;
  String credentialKey;
  String credentials;
  String flutterToken;

  User() {
    _doneFuture = _init();
  }

  Future get initializationDone => _doneFuture;

  bool isNull() {
    return this.UUID == null ||
        this.credentialKey == null ||
        this.credentials == null;
  }

  Future<User> _init() async {
    // attempt to get key if exists
    String userJsonString = await storage.read(key: "user");
    if (userJsonString != null) {
      try {
        var userJson = jsonDecode(userJsonString);
        this.UUID = userJson["UUID"];
        this.credentialKey = userJson["credentialKey"];
        this.credentials = userJson["credentials"];
        this.flutterToken = userJson["flutterToken"];
      } catch (error) {
        print(error);
      }
    }

    // get flutter token if android
    if (Platform.isAndroid) {
      // initiate firebase
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
      if (await storage.read(key: "firebase-token") == null) {
        print("creating new firebase token");
        _firebaseMessaging.getToken().then((token) async {
          this.flutterToken = token;
        });
      }
    }

    // create new credentials if any are missing
    if (this.isNull()) {
      // CREATE NEW USER
      var alreadyHadCredentials = false;
      if (this.UUID != null ||
          this.credentialKey != null ||
          this.credentials != null) {
        alreadyHadCredentials = true;
      }

      // Create new credentials as the user does not have any. it is completely
      // vital that this is successful so need to retry until it is.
      while (true) {
        await this.RequestNewUser();
        if (this.UUID != null) {
          break;
        }
        await new Future.delayed(Duration(seconds: 2));
        print("Retrying request for a new user");
      }

      if (alreadyHadCredentials) {
        // TODO return message to user to tell them that there credentials have been replaced
      }
    }
  }

  Future RequestNewUser() async {
    var data = {"UUID": Uuid().v4()};
    if (this.credentialKey != null) {
      data["current_credential_key"] = this.credentialKey;
    }
    if (this.credentials != null) {
      data["current_credentials"] = this.credentials;
    }
    await this._newUserReq(data);
  }

  Future _newUserReq(Map<String, dynamic> data) async {
    print("creating new user...");
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

    this.UUID = data["UUID"];
    this.credentialKey = credentialsMap["credential_key"];
    this.credentials = credentialsMap["credentials"];

    await storage.write(
        key: "user",
        value: jsonEncode({
          'UUID': this.UUID,
          'credentialKey': this.credentialKey,
          'credentials': this.credentials,
          'flutterToken': flutterToken,
        }));
  }
}
