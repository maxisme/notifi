import 'package:http/http.dart' as http;
import 'package:notifi/utils/utils.dart';

Map<String, Map<DateTime, http.Response>> cachedUrlResults;

Future<http.Response> get(String url,
    {int timeoutSeconds = 120, bool cacheErrors = false}) async {
  /* if timeOutSeconds == -1 - always uses cache */
  if (cachedUrlResults != null) {
    if (cachedUrlResults.containsKey(url)) {
      final DateTime cacheStart = cachedUrlResults[url].keys.last;
      if (timeoutSeconds == -1 ||
          DateTime.now().difference(cacheStart).inSeconds <= timeoutSeconds) {
        return cachedUrlResults[url][cacheStart];
      }
      // invalidate cache
      cachedUrlResults.remove(url);
    }
  } else {
    cachedUrlResults = <String, Map<DateTime, http.Response>>{};
  }

  final http.Response response = await http.get(url);
  if (!cacheErrors && response.statusCode != 200) {
    L.w('$url returned: ${response.statusCode}: not caching');
    return response;
  }
  cachedUrlResults[url] = <DateTime, http.Response>{DateTime.now(): response};
  return response;
}
