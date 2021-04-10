import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils.dart';
import 'package:web_socket_channel/io.dart';

Future<IOWebSocketChannel> connectToWS(
    UserStruct user,
    Future<List<String>> Function(String) onMessage,
    Function(bool) setErr) async {
  final Map<String, dynamic> headers = <String, dynamic>{
    'Sec-Key': env['SERVER_KEY'],
    'Uuid': user.uuid,
    'Credentials': user.credentials,
    'Key': user.credentialKey,
    'Version': await getVersionFromPubSpec(),
  };

  L.d('Connecting to WS...');
  setErr(false);
  IOWebSocketChannel ws = IOWebSocketChannel.connect(env['WS_ENDPOINT'],
      headers: headers, pingInterval: const Duration(seconds: 3));

  bool wsError = false;
  ws.stream.listen((dynamic streamData) async {
    wsError = false;
    final List<String> receivedMsgUUIDs = await onMessage(streamData);
    if (receivedMsgUUIDs != null) {
      ws.sink.add(jsonEncode(receivedMsgUUIDs));
    }
    // ignore: always_specify_types
  }, onError: (e) async {
    wsError = true;
    L.w('Problem with WS: $e');
  }, onDone: () async {
    L.d('WS connection closed.');
    if (wsError) {
      setErr(true);
      await Future<dynamic>.delayed(const Duration(seconds: 5));
    }
    ws.sink.close();
    ws = null; // not sure if needed
    ws = await connectToWS(user, onMessage, setErr);
  });

  return ws;
}
