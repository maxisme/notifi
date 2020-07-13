import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import 'notification.dart';

class NotificationProvider {
  Database db;

  Future open(String path) async {
    String dbPath = await getDatabasesPath() + "/" + path;

    print(dbPath);

    db = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
        create table if not exists Notifications ( 
        _id integer primary key autoincrement,       
        notification text not null,
        read int default 0)
      ''');
        });
  }

  Future<int> store(NotificationUI notification) async {
    return await db
        .insert("Notifications", {'notification': json.encode(notification)});
  }

  Future<int> delete(int id) async {
    return await db.delete("Notifications", where: '_id = ?', whereArgs: [id]);
  }

  Future deleteAll() async {
    await db.execute("DELETE FROM Notifications;");
  }

  Future toggleRead(int id, bool isRead) async {
    int read = 1;
    if (isRead) read = 0;
    await db.update(
        "Notifications", {"read": read}, where: '_id = ?', whereArgs: [id]);
  }

  Future markAllRead() async {
    await db.update("Notifications", {"read": "1"});
  }

  Future<List<Widget>> getAll() async {
    List<Widget> notifications = [];
    if (db == null) return notifications;

    List<Map> dbNotifications = await db.rawQuery(
        'SELECT _id, notification, read FROM Notifications ORDER BY _id DESC');

    for (var i = 0; i < dbNotifications.length; i++) {
      try {
        var notification = NotificationUI.fromJson(
            json.decode(dbNotifications[i]["notification"]));

        notification.read = false;
        if (dbNotifications[i]["read"] == 1){
          notification.read = true;
        }
        notification.id = dbNotifications[i]["_id"];
        notifications.add(notification);
      } catch (e) {
        print('Problem decoding notification in sql: $e - ' +
            dbNotifications[i][0]);
      }
    }
    return notifications;
  }
}
