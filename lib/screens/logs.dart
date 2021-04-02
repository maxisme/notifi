import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/utils.dart';

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
              future: L.logListView(),
              // ignore: always_specify_types
              builder: (BuildContext context, AsyncSnapshot f) {
                if (f.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return f.data;
              }),
        ));
  }
}
