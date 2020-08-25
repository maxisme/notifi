import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'notification.dart';

class NotificationProvider {
  Database db;

  Future initDB(String path) async {
    open.overrideFor(OperatingSystem.linux, _openOnLinux);

    String dbPath = "notifications.db";
    db = sqlite3.open(dbPath);

    db.execute('''
    CREATE TABLE IF NOT EXISTS Notifications ( 
      _id integer primary key autoincrement,       
      notification text not null,
      read int default 0
    );
    ''');
  }

  Future<int> store(NotificationUI notification) async {
    final stmt = db.prepare('INSERT INTO Notifications (notification) VALUES (?)');
    stmt.execute([json.encode(notification)]);
    stmt.dispose();
    return db.lastInsertRowId;
  }

  Future<int> delete(int id) async {
    final stmt = db.prepare('DELETE FROM Notifications where _id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future deleteAll() async {
    db.execute("DELETE FROM Notifications");
  }

  Future toggleRead(int id, bool isRead) async {
    int read = 1;
    if (isRead) read = 0;

    final stmt = db.prepare('UPDATE Notifications set read=? WHERE _id=?');
    stmt.execute([read, id]);
    stmt.dispose();
  }

  Future markAllRead() async {
    db.execute("UPDATE Notifications set read=1");
  }

  Future<List<Widget>> getAll() async {
    List<Widget> notifications = [];
    if (db == null) return notifications;

    ResultSet dbNotifications = db.select(
        'SELECT _id, notification, read FROM Notifications ORDER BY _id DESC');
    print(dbNotifications);
    return notifications;
  }

  DynamicLibrary _openOnLinux() {
    final libraryNextToScript = File('/home/maximilian/Documents/work/notifi/sqlite3.so');
    return DynamicLibrary.open(libraryNextToScript.path);
  }
}
