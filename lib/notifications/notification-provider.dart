import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'notification.dart';

class NotificationProvider {
  Database db;

  Future<Database> initDB(String path) async {
    open.overrideFor(OperatingSystem.linux, _openOnLinux);
    this.db = sqlite3.open("notifications.db");

    // language=SQLite
    this.db.execute('''
    CREATE TABLE IF NOT EXISTS notifications (
      _id integer primary key autoincrement,  
      UUID text unique not null,
      title text not null,
      time text not null,
      message text,
      image text,
      link text,
      read int default 0
    );
    ''');
  }

  int store(NotificationUI notification) {
    // language=SQLite
    final stmt = this.db.prepare('''
    INSERT INTO notifications 
      (UUID, title, time, message, image, link)
    VALUES 
      (?, ?, ?, ?, ?, ?)
    ''');
    stmt.execute([
      notification.UUID,
      notification.title,
      notification.time,
      notification.message,
      notification.image,
      notification.link,
    ]);
    stmt.dispose();
    return this.db.lastInsertRowId;
  }

  Future<int> delete(int id) async {
    // language=SQLite
    final stmt = this.db.prepare('DELETE FROM notifications where _id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future deleteAll() async {
    // language=SQLite
    this.db.execute("DELETE FROM notifications");
  }

  Future toggleRead(int id, bool isRead) async {
    int read = 0;
    if (isRead) read = 1;

    print(read);
    // language=SQLite
    final stmt = this.db.prepare('UPDATE notifications set read=? WHERE _id=?');
    stmt.execute([read, id]);
    stmt.dispose();
  }

  Future markAllRead() async {
    // language=SQLite
    this.db.execute("UPDATE notifications set read=1");
  }

  Future<List<Widget>> getAll() async {
    List<Widget> notifications = [];
    if (this.db == null) return notifications;

    // language=SQLite
    ResultSet dbNotifications = db.select('''
    SELECT * FROM notifications ORDER BY _id DESC''');
    var rows = dbNotifications.rows;
    if (rows != null) {
      for (var i = 0; i < rows.length; i++) {
        print(rows[i]);
        var n =
            new NotificationUI(rows[i][0], rows[i][2], rows[i][3], rows[i][1]);

        n.toggleRead(rows[0][7] == 1);
        notifications.add(n);
      }
    }
    return notifications;
  }

  DynamicLibrary _openOnLinux() {
    final libraryNextToScript =
        File('/home/maximilian/Documents/work/notifi/sqlite3.so');
    return DynamicLibrary.open(libraryNextToScript.path);
  }
}
