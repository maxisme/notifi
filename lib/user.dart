import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

final storage = new UserStore();

const RequestNewUserCode = 551;

class User with ChangeNotifier {
  Future _doneFuture;
  String UUID;
  String credentialKey;
  ValueListenable<String> credentials = ValueNotifier<String>("");
  String flutterToken;
  IOWebSocketChannel ws;

  User() {
    _doneFuture = _init();
  }

  Future get initializationDone => _doneFuture;

  bool isNull() {
    return this.UUID == null ||
        this.credentialKey == null ||
        this.credentials == null;
  }

  Future<bool> _init() async {
    // attempt to get key if exists
    await storage.getUser(this);

    // create new credentials if any are missing
    if (this.isNull()) {
      var alreadyHadCredentials = (this.UUID != null ||
          this.credentialKey != null ||
          this.credentials != null);

      // Create new credentials as the user does not have any. it is completely
      // vital that this is successful so need to retry until it is.
      bool gotUser = await this.RequestNewUser();

      if (alreadyHadCredentials) {
        // TODO return message to user to tell them that there credentials have been replaced
      }
    }
  }

  Future<bool> RequestNewUser() async {
    var data = {"UUID": Uuid().v4()}; // generate UUID for user
    if (this.credentialKey != null) {
      data["current_credential_key"] = this.credentialKey;
    }
    if (this.credentials != null) {
      data["current_credentials"] = this.credentials.value;
    }
    var gotUser = await this._newUserReq(data);
    if (gotUser == true && this.ws != null) {
      this.ws.sink.close(status.normalClosure, "new code!");
    }
  }

  Future<bool> _newUserReq(Map<String, dynamic> data) async {
    print("creating new user...");
    d.Dio dio = new d.Dio();
    var response;
    try {
      response = await dio.post("http://" + env['HOST'] + "/code",
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
    this.UUID = data["UUID"];
    this.credentialKey = credentialsMap["credential_key"];
    this.credentials = ValueNotifier<String>(credentialsMap["credentials"]);
    notifyListeners();

    // store user credentials
    await storage.writeUser(this);
    return true;
  }
}

class UserStore {
  final storage = new FlutterSecureStorage();
  static const key = "user";
  static const linuxFile = "user-store.json";

  Future<void> getUser(User user) async {
    var userJsonString;
    try {
      userJsonString = await storage.read(key: key);
    } on MissingPluginException catch (e) {
      // read json from file
      var file = await _getLinuxFile();
      userJsonString = await file.readAsString();
    }

    if (userJsonString != null) {
      try {
        var userJson = jsonDecode(userJsonString);
        user.UUID = userJson["UUID"];
        user.credentialKey = userJson["credentialKey"];
        user.credentials = ValueNotifier<String>(userJson["credentials"]);
        user.flutterToken = userJson["flutterToken"];
      } catch (error) {
        print(error);
      }
    }
    return user;
  }

  Future writeUser(User user) async {
    String jsonData = jsonEncode({
      'UUID': user.UUID,
      'credentialKey': user.credentialKey,
      'credentials': user.credentials.value,
    });
    try {
      await storage.write(key: key, value: jsonData);
    } on MissingPluginException catch (e) {
      // write to file instead of keychain
      var file = await _getLinuxFile();
      file.writeAsString(jsonData);
    }
  }

  Future<File> _getLinuxFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/.notifi/' + linuxFile;
    File file = File(savePath);
    file.create(recursive: true);
    return file;
  }
}
