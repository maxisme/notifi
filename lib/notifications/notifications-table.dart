import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationTable extends StatefulWidget {
  final User user;
  void Function(int id) toggleExpand;
  void Function(int id) toggleRead;
  void Function(int id) delete;
  void Function() setUnreadCnt;
  void Function(bool err) setError;
  Future<List<NotificationUI>> Function() getAll;

  NotificationTableState notificationTableState = new NotificationTableState();

  NotificationTable(this.user, {Key key}){
    print('init1');
  }

  add(NotificationUI notification) {
    notificationTableState.insert(notification);
  }

  getNotification(int index) {
    return notificationTableState.notifications[index];
  }

  deleteNotification(int index) {
    notificationTableState.removeAt(index);
  }

  unreadCnt() {
    int cnt = 0;
    if (notificationTableState.notifications != null) {
      for (var i = 0; i < notificationTableState.notifications.length; i++) {
        if (!notificationTableState.notifications[i].isRead) {
          cnt++;
        }
      }
    }
    return cnt;
  }

  deleteAll() {
    notificationTableState.deleteAll();
  }

  readAll() {
    notificationTableState.readAll();
  }

  @override
  NotificationTableState createState() => notificationTableState;
}

class NotificationTableState extends State<NotificationTable>
    with TickerProviderStateMixin {
  List<NotificationUI> notifications = List.empty(growable: true);

  Widget _buildNotification(
      BuildContext context, int index, Animation<double> animation) {

    final NotificationUI notification = this.notifications[index];
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
                icon: Icons.copy,
                caption: "Title",
                onTap: () {
                  Clipboard.setData(new ClipboardData(text: notification.title));
                },
              ),
              IconSlideAction(
                color: MyColour.offWhite,
                icon: Icons.copy,
                caption: "Message",
                onTap: () async {
                  Clipboard.setData(new ClipboardData(text: notification.message));
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

  insert(NotificationUI notification) {
    print(notification.title);
    this.notifications.insert(0, notification);

    if (this.notifications.length == 1) {
      // going from no notifications to table
      setState(() {});
    } else {
      listKey.currentState.insertItem(0, duration: Duration(milliseconds: 500));
    }
  }

  removeAt(int index) {
    this.notifications.removeAt(index);
    // listKey.currentState.removeItem(index, );
  }

  readAll() {
    if (this.notifications != null) {
      setState(() {
        for (var i = 0; i < this.notifications.length; i++) {
          this.notifications[i].isRead = true;
        }
      });
    }
  }

  deleteAll() {
    setState(() {
      this.notifications.clear();
      this.notifications = List.empty(growable: true);
      print(this.notifications.length);
    });
  }

  GlobalKey<AnimatedListState> listKey;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.getAll(),
      builder: (context, f) {
        if (f.hasError) {
          print(f.error);
        }
        listKey = null;
        if (f.hasData && f.data.length > 0) {
          if(f.connectionState == ConnectionState.done) {
            this.notifications = f.data;
            print("reloaded $f");
            widget.setUnreadCnt();
          }
          listKey = GlobalKey<AnimatedListState>();
          return AnimatedList(
              key: listKey,
              itemBuilder: _buildNotification,
              initialItemCount: this.notifications.length);
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
                  SelectableText("No notifications!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColour.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 35)),
                  Container(padding: const EdgeInsets.only(top: 20.0)),
                  ValueListenableBuilder<String>(
                      valueListenable: widget.user.credentials,
                      builder:
                          (BuildContext context, String value, Widget child) {
                        var credentials = value;
                        if (credentials == "") {
                          credentials = "...";
                        }
                        return Column(children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'To receive notifications use ',
                                  style: TextStyle(
                                      color: MyColour.grey,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inconsolata'),
                                ),
                                TextSpan(
                                  text: 'HTTP Requests',
                                  style: TextStyle(
                                      color: MyColour.red,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inconsolata'),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      launch("https://notifi.it?c=" +
                                          widget.user.credentials.value +
                                          "#how-to");
                                    },
                                ),
                                TextSpan(
                                  text: ' with your credentials...',
                                  style: TextStyle(
                                      color: MyColour.grey,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inconsolata'),
                                ),
                              ],
                            ),
                          ),
                          Container(padding: const EdgeInsets.only(top: 20.0)),
                          SelectableText(credentials,
                              textAlign: TextAlign.center, onTap: () {
                            Clipboard.setData(
                                new ClipboardData(text: credentials));
                            Toast.show("Copied " + credentials, context,
                                gravity: Toast.BOTTOM);
                          },
                              style: TextStyle(
                                  color: MyColour.red,
                                  fontWeight: FontWeight.w900))
                        ]);
                      })
                ]),
          );
        }
      },
    );
  }
}
