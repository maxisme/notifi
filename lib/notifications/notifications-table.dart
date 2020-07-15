import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';

import 'notification-provider.dart';

class NotificationTable extends StatefulWidget {
  final NotificationProvider notificationDB;
  User user;

  NotificationTableState notificationTableState = new NotificationTableState();

  NotificationTable(this.user, this.notificationDB, {Key key})
      : super(key: key);

  Future<int> add(NotificationUI notification) async {
    notification.id = await this.notificationDB.store(notification);
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

class NotificationTableState extends State<NotificationTable> {
  List<Widget> notifications;
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();

  Widget _buildNotification(BuildContext context, int index) {
    if (this.notifications.length > index) {
      // TODO this check is hacky find out actual problem

      final NotificationUI notification = this.notifications[index];

      var linkSlider;
      if (notification.link.length > 0) {
        linkSlider = IconSlideAction(
          color: MyColour.offWhite,
          icon: Icons.link,
          onTap: () {
            notification.launchLink();
          },
        );
      }
      return Slidable(
          key: Key(notification.id.toString()),
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          dismissal: SlidableDismissal(
            dismissThresholds: <SlideActionType, double>{
              SlideActionType.primary: 1.0
            },
            child: SlidableDrawerDismissal(),
            onDismissed: (actionType) {
              setState(() {
                widget.notificationDB.delete(notification.id);
                this.notifications.removeAt(index);
              });
            },
          ),
          actions: <Widget>[
            IconSlideAction(
              color: MyColour.offWhite,
              icon: Icons.remove_red_eye,
              onTap: () {
                bool read = false;
                if (notification.read != null && notification.read) read = true;
                widget.notificationDB.toggleRead(notification.id, read);
                notification.read = !read;
              },
            ),
            if (linkSlider != null) linkSlider
          ],
          secondaryActions: <Widget>[
            IconSlideAction(
              color: MyColour.offWhite,
              icon: Icons.delete,
              onTap: () {
                setState(() {
                  widget.notificationDB.delete(notification.id);
                  this.notifications.removeAt(index);
                });
              },
            ),
          ],
          child: notification);
    }
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
      future: widget.notificationDB.getAll(),
      builder: (context, f) {
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
            child: Column(children: [
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
              SelectableText(widget.user.credentials,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: MyColour.red, fontWeight: FontWeight.w900)),
            ]),
          );
        }
      },
    );
  }
}
