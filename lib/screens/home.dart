import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notification-provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifications-table.dart';

import '../pallete.dart';

class HomeScreen extends StatefulWidget {
  NotificationTable table;
  NotificationProvider db;

  HomeScreen(this.table, this.db, {Key key}) : super(key: key);

  Future<int> add(NotificationUI notification) async {
    // returns -1 if failed
    int id;
    try {
      id = await this.db.store(notification);
    } catch (e) {
      print("Problem storing notification: $e");
      id = -1;
    }
    if (id != -1) {
      notification.id = id;
      this.table.add(notification);
      this.table.setUnreadCnt();
    }
    return id;
  }

  setError(bool err) {
    try {
      this.table.setError(err);
    } catch (e) {
      print(e);
    }
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<int> _unreadCnt;
  ValueNotifier<bool> _networkError;

  @override
  void initState() {
    _unreadCnt = ValueNotifier<int>(0);
    _networkError = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    _unreadCnt.dispose();
    _networkError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // initiate helper functions
    widget.table.toggleRead = toggleRead;
    widget.table.toggleExpand = toggleExpand;
    widget.table.delete = deleteNotification;
    widget.table.setUnreadCnt = setUnreadCnt;
    widget.table.setError = setError;
    widget.table.getAll = widget.db.getAll;

    const double leadingWidth = 60.0;
    return Scaffold(
        backgroundColor: MyColour.offWhite,
        appBar: AppBar(
          shape: Border(bottom: BorderSide(color: MyColour.offGrey)),
          elevation: 0.0,
          toolbarHeight: 80,
          title: Container(
            padding: const EdgeInsets.only(right: leadingWidth),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      alignment: Alignment(0, 0),
                      child: SizedBox(
                          height: 50,
                          child: Image.asset('images/bell.png',
                              filterQuality: FilterQuality.high)),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: ValueListenableBuilder(
                            valueListenable: _unreadCnt,
                            builder: (context, value, child) {
                              if (value != 0) {
                                if (value > 99) {
                                  value = "99+";
                                } else {
                                  value = value.toString();
                                }
                                return Container(
                                  alignment: Alignment(0.1, 0),
                                  child: CircleAvatar(
                                      backgroundColor: MyColour.red,
                                      radius: 10,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: MyColour.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )),
                                );
                              }
                              return Container(width: 0, height: 0);
                            })),
                  ],
                ),
                ValueListenableBuilder(
                    valueListenable: _networkError,
                    builder: (context, value, child) {
                      if (value) {
                        return Text("Network error!",
                            style:
                                TextStyle(color: MyColour.grey, fontSize: 10));
                      }
                      return Container();
                    })
              ],
            ),
          ),
          leadingWidth: leadingWidth,
          leading: IconButton(
              icon: Icon(
                Navigator.canPop(context) ? Icons.arrow_back : Icons.settings,
                color: MyColour.grey,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(context, '/settings');
                }
              }),
        ),
        body: widget.table,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) async {
            if (index == 0) {
              // MARK ALL AS READ EVENT
              await markAllRead();
            } else if (index == 1) {
              // DELETE ALL EVENT
              _deleteAllNotificationsDialogue();
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.done_all, color: MyColour.darkGrey),
              title: Text('Mark All Read',
                  style: TextStyle(
                      color: MyColour.grey,
                      fontSize:
                          14)), // no idea why this needs to be 14 to match the other button
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.delete_outline, color: MyColour.darkGrey),
                title: Text('Delete All',
                    style: TextStyle(color: MyColour.grey, fontSize: 12))),
          ],
          currentIndex: 1,
        ));
  }

  Future<void> _deleteAllNotificationsDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete All'),
          content: Text('All notifications will be irretrievable'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: MyColour.grey),
              ),
            ),
            TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: MyColour.black),
                ),
                onPressed: () {
                  deleteAll();
                  Navigator.pop(context);
                  setState(() {});
                })
          ],
        );
      },
    );
  }

  setUnreadCnt() {
    int cnt = 0;
    if (widget.table.notifications != null) {
      for (var i = 0; i < widget.table.notifications.length; i++) {
        if (!widget.table.notifications[i].isRead) {
          cnt++;
        }
      }
    }
    this._unreadCnt.value = cnt;
  }

  setError(bool err) {
    this._networkError.value = err;
  }

  toggleExpand(int index) async {
    NotificationUI notification = widget.table.notifications[index];

    bool isExpanded = false;
    if (notification.isExpanded) isExpanded = true;
    notification.isExpanded = !isExpanded;
    Scrollable.ensureVisible(this.context);

    // mark read
    await widget.db.markRead(notification.id, true);
    notification.isRead = true;
    setUnreadCnt();
  }

  toggleRead(int index) async {
    NotificationUI notification = widget.table.notifications[index];
    bool read = true;
    if (notification.isRead) read = false;
    notification.isRead = read;
    setUnreadCnt();
    await widget.db.markRead(notification.id, read);
  }

  deleteNotification(int index) async {
    NotificationUI notification = widget.table.notifications[index];

    await widget.db.delete(notification.id);
    widget.table.notifications.removeAt(index);

    setUnreadCnt();
  }

  deleteAll() async {
    await widget.db.deleteAll();
    widget.table.deleteAll();
    setUnreadCnt();
  }

  markAllRead() async {
    await widget.db.markAllRead();
    widget.table.readAll();
    setUnreadCnt();
  }
}
