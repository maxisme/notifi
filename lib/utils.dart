import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

const platform = const MethodChannel('max.me.uk/notifications');
const refKey = "ref";
const messageKey = "msg";


Future<void> invokeMethod(method) async {
  try {
    await platform.invokeMethod(method);
  } on PlatformException catch (e) {
    print("Failed to invoke method ($method): '${e.message}'.");
  }
}

Future<String> getVersionFromPubSpec() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}
