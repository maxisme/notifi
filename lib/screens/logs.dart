import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/utils/pallete.dart';

class LogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text('Logs'),
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: FutureBuilder<ListView>(
              future: logListView(),
              // ignore: always_specify_types
              builder: (BuildContext context, AsyncSnapshot f) {
                if (f.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return f.data;
              }),
        ));
  }

  static Future<ListView> logListView() async {
    final List<Log> logs = await FLog.getAllLogs();

    final List<Container> rows = <Container>[];
    for (int i = logs.length - 1; i >= logs.length - 100; i--) {
      final Log log = logs[i];
      rows.add(Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: log.logLevel
                      .toString()
                      .replaceAll('LogLevel.', '')
                      .substring(0, 4),
                  style: const TextStyle(
                      color: MyColour.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Inconsolata'),
                ),
                TextSpan(
                  text: ' ~ ${log.timestamp}\n',
                  style: const TextStyle(
                      color: MyColour.grey,
                      fontWeight: FontWeight.w100,
                      fontSize: 12,
                      fontFamily: 'Inconsolata'),
                ),
                TextSpan(
                  text: log.text,
                  style: const TextStyle(
                      color: MyColour.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Inconsolata'),
                ),
              ])),
            ),
          ],
        ),
      ));
    }
    return ListView(children: rows);
  }
}
