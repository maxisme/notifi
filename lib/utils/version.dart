import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> hasUpgrade(String version) async {
  String versionEndpoint = env['VERSION_ENDPOINT'];
  if (versionEndpoint.contains('?')) {
    versionEndpoint += '&';
  } else {
    versionEndpoint += '?';
  }
  versionEndpoint += 'version=$version';
  final http.Response response = await http.get(versionEndpoint);
  return response.statusCode == 200;
}
