import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';

import 'notification-provider.dart';

class NotificationTable extends StatefulWidget {
  NotificationProvider notificationDB;
  final User user;

  NotificationTableState notificationTableState = new NotificationTableState();

  NotificationTable(this.user) {
    this.notificationDB = NotificationProvider();
    this.notificationDB.initDB("notifications.db");
  }

  int add(NotificationUI notification) {
    notification.id = this.notificationDB.store(notification);
    notificationTableState.insert(notification);
    return notification.id;
  }

  Future deleteAll() async {
    await this.notificationDB.deleteAll();
    notificationTableState.deleteAll();
  }

  @override
  NotificationTableState createState() => notificationTableState;
}

class NotificationTableState extends State<NotificationTable>
    with TickerProviderStateMixin {
  List<Widget> notifications;
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();

  Widget _buildNotification(BuildContext context, int index) {
    if (this.notifications.length > index) {
      final NotificationUI notification = this.notifications[index];

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
                onDismissed: (_) {
                  deleteNotification(notification.id, index);
                },
              ),
              actions: <Widget>[
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Icons.check,
                  onTap: () {
                    setState(() {
                      readNotification(notification);
                    });
                  },
                ),
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Icons.zoom_out_map,
                  onTap: () {
                    bool isExpanded = false;
                    if (notification.isExpanded) isExpanded = true;
                    notification.isExpanded = !isExpanded;
                    print(!isExpanded);
                    Scrollable.ensureVisible(this.context);
                  },
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Icons.delete,
                  onTap: () {
                    deleteNotification(notification.id, index);
                  },
                ),
              ],
              child: notification));
    }
  }

  readNotification(NotificationUI notification) {
    bool read = false;
    if (notification.isRead) read = true;
    widget.notificationDB.toggleRead(notification.id, read);
    notification.isRead = !read;
  }

  deleteNotification(int notificationID, int index) {
    widget.notificationDB.delete(notificationID);
    this.notifications.removeAt(index);
  }

  insert(NotificationUI notification) {
    if (this.notifications == null) {
      this.notifications = [];
    }
    final index = this.notifications.length;
    this.notifications.insert(0, notification);
    if (_listKey.currentState == null) {
      setState(() {});
    }
    if (_listKey.currentState != null) {
      _listKey.currentState
          .insertItem(index, duration: Duration(milliseconds: 500));
    }
  }

  deleteAll() {
    setState(() {
      this.notifications = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getNotifications(widget),
      builder: (context, f) {
        if (f.hasError) {
          print(f.error);
        }
        if (f.hasData != null && f.data != null && f.data.length > 0) {
          List<Widget> notifications = f.data;
          this.notifications = notifications;
          return new ListView.builder(
              key: _listKey,
              itemBuilder: _buildNotification,
              itemCount: this.notifications.length);
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

  Future<List<Widget>> _getNotifications(NotificationTable widget) async {
    // return all notifications
    return widget.notificationDB.getAll();
  }
}
