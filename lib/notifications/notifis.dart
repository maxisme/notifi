import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:notifi/notifications/db_provider.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/utils/utils.dart';

class Notifications extends ChangeNotifier {
  Notifications(this.notifications, this.db, this.tableNotifier,
      {this.canBadge});

  ReloadTable tableNotifier;
  DBProvider db;
  final bool canBadge; // is allowed to set badge on app icon
  List<NotificationUI> notifications = List<NotificationUI>.empty();
  GlobalKey<AnimatedListState> tableKey = GlobalKey<AnimatedListState>();
  ScrollController tableController = ScrollController();

  // ignore: use_setters_to_change_properties
  void setTableNotifier(ReloadTable tableNotifier) {
    this.tableNotifier = tableNotifier;
  }

  int get length => notifications.length;

  NotificationUI get(int index) {
    return notifications[index];
  }

  void scrollToTop() {
    if (tableController.hasClients) {
      tableController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
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
      MenuBarIcon.set('red');
    } else {
      MenuBarIcon.set('grey');
    }

    if (canBadge) {
      FlutterAppBadger.updateBadgeCount(cnt);
    }

    return cnt;
  }

  Future<int> add(NotificationUI notification) async {
    int id;
    try {
      id = await db.store(notification);
    } catch (e) {
      L.e('Problem storing notification in db: $e');
      return -1;
    }

    notification.id = id;
    notifications.insert(0, notification);
    if (notifications.length == 1) {
      tableNotifier.reloadTable();
    } else {
      // scroll to top of table
      scrollToTop();

      // animate in notification
      if (tableKey.currentState != null) {
        tableKey.currentState
            .insertItem(0, duration: const Duration(seconds: 1));
      }
    }

    if (canBadge) {
      FlutterAppBadger.updateBadgeCount(unreadCnt);
    }

    notifyListeners();
    return id;
  }

  Future<void> delete(int index) async {
    final int id = notifications[index].id;
    await db.delete(id);
    notifications.removeAt(index);
    if (notifications.isEmpty) {
      tableNotifier.reloadTable();
    } else {
      // animate out notification
      tableKey.currentState.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        final Animation<Offset> _offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.0),
          end: const Offset(1, 0),
        ).animate(ReverseAnimation(animation));

        return SlideTransition(
          position: _offsetAnimation,
          child: get(index),
        );
      }, duration: const Duration(milliseconds: 300));
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
  }
}

class ReloadTable extends ChangeNotifier {
  void reloadTable() {
    notifyListeners();
  }
}
