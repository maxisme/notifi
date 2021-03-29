import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/db_provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/utils.dart';

class Notifications extends ChangeNotifier {
  Notifications(this.notifications, this.db, this.tableNotifier);

  ReloadTable tableNotifier;
  DBProvider db;
  List<NotificationUI> notifications = List<NotificationUI>.empty();
  GlobalKey<AnimatedListState> tableKey = GlobalKey<AnimatedListState>();

  // ignore: use_setters_to_change_properties
  void setTableNotifier(ReloadTable tableNotifier) {
    this.tableNotifier = tableNotifier;
  }

  int get length => notifications.length;

  NotificationUI get(int index) {
    return notifications[index];
  }

  int get unreadCnt {
    int cnt = 0;
    if (notifications != null) {
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          cnt++;
        }
      }
    }

    if (cnt > 0) {
      invokeMacMethod('red_menu_icon');
    } else {
      invokeMacMethod('grey_menu_icon');
    }

    return cnt;
  }

  Future<int> add(NotificationUI notification) async {
    int id;
    try {
      id = await db.store(notification);
    } catch (e) {
      print('Problem storing notification in db: $e');
      return -1;
    }

    notification.id = id;
    notifications.insert(0, notification);
    if (notifications.length == 1) {
      tableNotifier.reloadTable();
    } else {
      tableKey.currentState.insertItem(0, duration: const Duration(seconds: 1));
    }
    notifyListeners();
    return id;
  }

  Future<void> delete(int index) async {
    final int id = notifications[index].id;
    await db.delete(id);
    notifications.removeAt(index);
    tableKey.currentState.removeItem(
        index, (BuildContext context, Animation<double> animation) => null);
    if (notifications.isEmpty) {
      tableNotifier.reloadTable();
    }
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await db.deleteAll();
    notifications.clear();
    tableNotifier.reloadTable();
    tableKey = GlobalKey<AnimatedListState>();
    notifyListeners();
    tableNotifier.reloadTable();
  }

  Future<void> markRead(int index, {bool isRead}) async {
    notifications[index].read = isRead;
    await db.markRead(notifications[index].id, isRead: isRead);
    notifyListeners();
  }

  Future<void> toggleRead(int index) async {
    final NotificationUI notification = notifications[index];
    markRead(index, isRead: !notification.isRead);
    notifyListeners();
  }

  Future<void> readAll() async {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i].read = true;
    }
    await db.markAllRead();
    notifyListeners();
    tableNotifier.reloadTable();
  }
}

class ReloadTable extends ChangeNotifier {
  void reloadTable() {
    notifyListeners();
  }
}
