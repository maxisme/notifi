import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/screens/base.dart';

class HomeScreen extends StatefulWidget {
  NotificationTable table;
  void newUserCallback;

  HomeScreen(this.table, {Key key, this.newUserCallback}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(widget.table, widget.table);
  }
}
