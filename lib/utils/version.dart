import 'package:http/http.dart' as http;
import 'package:notifi/utils/utils.dart';

Future<bool> hasUpgrade(String version) async {
  String endpoint = versionEndpoint;
  if (endpoint.contains('?')) {
    endpoint += '&';
  } else {
    endpoint += '?';
  }
  endpoint += 'version=$version';
  final http.Response response = await http.get(endpoint);
  return response.statusCode == 200;
}
