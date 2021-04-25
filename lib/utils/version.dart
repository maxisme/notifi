import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notifi/utils/cache_http.dart';
import 'package:notifi/utils/utils.dart';

Future<String> getUpdateURL(String version) async {
  final bool versionIsPrerelease = await isPrerelease(version);

  final http.Response response =
      await get('https://api.github.com/repos/maxisme/notifi/releases');
  if (response.statusCode != 200) {
    L.w(response.body);
    return '';
  }
  final dynamic releases = jsonDecode(response.body);

  String latestPrerelease = '';
  String latestNotPrerelease = '';
  for (int i = 0; i < releases.length; i++) {
    final String dmg = releases[i]['assets'][0]['browser_download_url'];
    if (releases[i]['tag_name'] == version) {
      if (versionIsPrerelease) {
        return latestPrerelease;
      } else {
        return latestNotPrerelease;
      }
    } else if (latestPrerelease == '' && releases[i]['prerelease']) {
      latestPrerelease = dmg;
    } else if (latestNotPrerelease == '') {
      latestNotPrerelease = dmg;
    }
  }

  L.w('Unable to find out if there is an update or not...');
  return latestNotPrerelease;
}

Future<bool> isPrerelease(String version) async {
  final http.Response response = await get(
      'https://api.github.com/repos/maxisme/notifi/releases/tags/$version',
      timeoutSeconds: -1,
      cacheErrors: true);

  if (response.statusCode != 200) {
    L.w('isPrerelease: returned:${response.statusCode}');
  }

  final Map<String, dynamic> release =
      jsonDecode(response.body) as Map<String, dynamic>;
  return release['prerelease'];
}
