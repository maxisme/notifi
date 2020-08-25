import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

final storage = new UserStore();

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

  Future _init() async {
    // attempt to get key if exists
    await storage.set(this);

    // get flutter token if android
//    if (Platform.isAndroid) {
//      // initiate firebase
//      FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//      if (await storage.read(key: "firebase-token") == null) {
//        print("creating new firebase token");
//        _firebaseMessaging.getToken().then((token) async {
//          this.flutterToken = token;
//        });
//      }
//    }

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
      await this.RequestNewUser();

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

    await storage.write(this);
  }
}

class UserStore {
  final storage = new FlutterSecureStorage();
  static const key = "user";
  static const linuxFile = "user-store.json";

  Future<void> set(User user) async{
    var userJsonString;
    try {
      userJsonString = await storage.read(key: key);
    } on MissingPluginException catch(e) {
      // read json from file
      var file = await getLinuxFile();
      userJsonString = await file.readAsString();
    }

    if (userJsonString != null) {
      try {
        var userJson = jsonDecode(userJsonString);
        user.UUID = userJson["UUID"];
        user.credentialKey = userJson["credentialKey"];
        user.credentials = userJson["credentials"];
        user.flutterToken = userJson["flutterToken"];
      } catch (error) {
        print(error);
      }
    }
    return user;
  }

  Future write(User user) async{
    String jsonData = jsonEncode({
      'UUID': user.UUID,
      'credentialKey': user.credentialKey,
      'credentials': user.credentials,
    });
    try {
      await storage.write(key: key, value: jsonData);
    } on MissingPluginException catch(e) {
      var file = await getLinuxFile();
      file.writeAsString(jsonData);
    }
  }

  Future<File> getLinuxFile() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/'+linuxFile;

    File file = File(savePath);
    if (!await file.exists()) {
      await file.writeAsString("");
    }
    return file;
  }
}