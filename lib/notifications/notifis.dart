import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/db-provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/utils.dart';

class Notifications extends ChangeNotifier {
  ReloadTable tableNotifier;
  DBProvider db;
  List<NotificationUI> notifications = List.empty();
  GlobalKey<AnimatedListState> tableKey = GlobalKey<AnimatedListState>();

  Notifications(this.notifications, this.db, this.tableNotifier, {Key key});

  setTableNotifier(ReloadTable tableNotifier) {
    this.tableNotifier = tableNotifier;
  }

  int get length => notifications.length;

  NotificationUI get(int index) {
    return notifications[index];
  }

  int get unreadCnt {
    int cnt = 0;
    if (notifications != null) {
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          cnt++;
        }
      }
    }

    if (cnt > 0) {
      invokeMacMethod("red_menu_icon");
    } else {
      invokeMacMethod("grey_menu_icon");
    }

    return cnt;
  }

  Future<int> add(NotificationUI notification) async {
    int id;
    try {
      id = await db.store(notification);
    } catch (e) {
      print("Problem storing notification in db: $e");
      return -1;
    }

    notification.id = id;
    notifications.insert(0, notification);
    if (notifications.length == 1) {
      tableNotifier.reloadTable();
    } else {
      tableKey.currentState.insertItem(0, duration: Duration(seconds: 1));
    }
    notifyListeners();
    return id;
  }

  void delete(int index) async {
    var id = notifications[index].id;
    await db.delete(id);
    notifications.removeAt(index);
    tableKey.currentState.removeItem(index, (context, animation) => null);
    if (notifications.isEmpty) {
      tableNotifier.reloadTable();
    }
    notifyListeners();
  }

  void deleteAll() async {
    await db.deleteAll();
    notifications.clear();
    tableNotifier.reloadTable();
    tableKey = GlobalKey<AnimatedListState>();
    notifyListeners();
    tableNotifier.reloadTable();
  }

  void markRead(int index, bool isRead) async {
    notifications[index].isRead = isRead;
    await db.markRead(notifications[index].id, isRead);
    notifyListeners();
  }

  void toggleRead(int index) async {
    NotificationUI notification = notifications[index];
    markRead(index, !notification.isRead);
    notifyListeners();
  }

  void readAll() async {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i].isRead = true;
    }
    await db.markAllRead();
    notifyListeners();
    tableNotifier.reloadTable();
  }
}

class ReloadTable extends ChangeNotifier {
  reloadTable() {
    notifyListeners();
  }
}
