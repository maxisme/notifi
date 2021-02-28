import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';

import 'notification-provider.dart';

class NotificationTable extends StatefulWidget {
  final User user;
  List<NotificationUI> notifications;
  void Function(int id) toggleExpand;
  void Function(int id) toggleRead;
  void Function(int id) delete;
  Future<int> Function(NotificationUI notification) store;
  Future<List<NotificationUI>> Function() getAll;

  NotificationTableState notificationTableState = new NotificationTableState();

  NotificationTable(this.user, {Key key}) : super(key: key);

  Future<int> add(NotificationUI notification) async {
    notification.id = await this.store(notification);
    notificationTableState.insert(notification);
    return notification.id;
  }

  deleteAll(){
    notificationTableState.deleteAll();
  }

  readAll(){
    notificationTableState.readAll();
  }

  @override
  NotificationTableState createState() => notificationTableState;
}

class NotificationTableState extends State<NotificationTable>
    with TickerProviderStateMixin {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();

  Widget _buildNotification(BuildContext context, int index) {
    if (widget.notifications.length > index) {
      final NotificationUI notification = widget.notifications[index];
      notification.index = index;
      notification.toggleExpand = widget.toggleExpand;
      notification.toggleRead = widget.toggleRead;

      return AnimatedSize(
          vsync: this,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Slidable(
              key: Key(notification.id.toString()),
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.2,
              dismissal: SlidableDismissal(
                dismissThresholds: <SlideActionType, double>{
                  SlideActionType.primary: 1.0
                },
                child: SlidableDrawerDismissal(),
                onDismissed: (_) async {
                  await widget.delete(index);
                },
              ),
              actions: <Widget>[
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Icons.check,
                  onTap: () {
                    widget.toggleRead(index);
                    setState(() {});
                  },
                ),
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Icons.zoom_out_map,
                  onTap: () async {
                    await widget.toggleRead(index);
                  },
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Icons.delete,
                  onTap: () {
                    setState(() {
                      widget.delete(index);
                    });
                  },
                ),
              ],
              child: notification));
    }
  }

  insert(NotificationUI notification) {
    if (widget.notifications == null) {
      widget.notifications = [];
    }
    final index = widget.notifications.length;
    widget.notifications.insert(0, notification);
    if (_listKey.currentState == null) {
      setState(() {});
    }
    if (_listKey.currentState != null) {
      _listKey.currentState
          .insertItem(index, duration: Duration(milliseconds: 500));
    }
  }

  readAll(){
    for (var i = 0; i < widget.notifications.length; i++) {
      widget.notifications[i].isRead = true;
    }
    setState(() {});
  }

  deleteAll(){
    widget.notifications = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.getAll(),
      builder: (context, f) {
        if (f.hasError) {
          print(f.error);
        }
        if (f.hasData != null && f.data != null && f.data.length > 0) {
          List<NotificationUI> notifications = f.data;
          widget.notifications = notifications;
          return new ListView.builder(
              key: _listKey,
              itemBuilder: _buildNotification,
              itemCount: widget.notifications.length);
        } else {
          // NO notifications
          return Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.only(top: 20.0)),
                  Image.asset('images/sad.png',
                      height: 150, filterQuality: FilterQuality.high),
                  Container(padding: const EdgeInsets.only(top: 20.0)),
                  SelectableText("No Notifications!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColour.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 35)),
                  Container(padding: const EdgeInsets.only(top: 20.0)),
                  SelectableText(
                      "To receive notifications use HTTP Requests with your credentials...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColour.grey, fontWeight: FontWeight.w500)),
                  Container(padding: const EdgeInsets.only(top: 20.0)),
                  ValueListenableBuilder<String>(
                    valueListenable: widget.user.credentials,
                    builder:
                        (BuildContext context, String value, Widget child) {
                      var credentials = value;
                      if (credentials == "") {
                        credentials = "...";
                      }
                      return SelectableText(credentials,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyColour.red,
                              fontWeight: FontWeight.w900));
                    },
                  )
                  // if (widget.user == null || widget.user.credentials == null)
                  //   Column(children: [
                  //     Container(
                  //       padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                  //       child: Text("Problem connecting to server..."),
                  //     ),
                  //     Container(r
                  //         height: 40.0,
                  //         width: 40.0,
                  //         child: FittedBox(
                  //             child: FloatingActionButton(
                  //           child: Text(
                  //             "Retry",
                  //             style: TextStyle(fontSize: 12),
                  //           ),
                  //           onPressed: () {
                  //             setState(() {});
                  //           },
                  //         ))),
                  //   ])
                ]),
          );
        }
      },
    );
  }
}
