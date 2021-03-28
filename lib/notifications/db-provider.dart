import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// import 'package:sqlite3/sqlite3.dart';

import 'notification.dart';

class DBProvider {
  String table = 'notifications';
  String dbPath = "notifications.db";

  Future<Database> initDB() async {
    return openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        join(await getDatabasesPath(), dbPath), onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE IF NOT EXISTS ${this.table} (
          _id integer primary key autoincrement, 
          UUID text unique not null,
          title text not null,
          time text not null,
          message text,
          image text,
          link text,
          read integer default 0
        );
        ''');
    }, version: 1);
  }

  Future<int> store(NotificationUI notification) async {
    final Database db = await initDB();
    return await db.rawInsert('''
        INSERT INTO ${this.table} 
          (UUID, title, time, message, image, link)
        VALUES 
          (?, ?, ?, ?, ?, ?)
        ''', [
      notification.UUID,
      notification.title,
      notification.time,
      notification.message,
      notification.image,
      notification.link,
    ]);
  }

  Future<int> delete(int id) async {
    final Database db = await initDB();
    return await db.delete(this.table, where: "_id = ?", whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final Database db = await initDB();
    return await db.rawDelete("DELETE FROM ${this.table}");
  }

  Future<int> markRead(int id, bool isRead) async {
    int read = 0;
    if (isRead) read = 1;
    final Database db = await initDB();
    return await db.rawUpdate("UPDATE ${this.table} SET read=? WHERE _id=?", [read, id]);
  }

  Future<int> markAllRead() async {
    final Database db = await initDB();
    return await db.rawUpdate("UPDATE ${this.table} SET read=?", [1]);
  }

  Future<List<NotificationUI>> getAll() async {
    List<NotificationUI> notifications = List.empty(growable: true);
    final Database db = await initDB();

    // language=SQLite
    final List<Map<String, dynamic>> rows = await db.rawQuery('''
    SELECT * FROM notifications ORDER BY _id DESC''');

    for (var i = 0; i < rows.length; i++) {
      bool isRead = false;
      if (rows[i]['read'] == 1) {
        isRead = true;
      }

      notifications.add(new NotificationUI(
        rows[i]['_id'],
        rows[i]['title'],
        rows[i]['time'],
        rows[i]['UUID'],
        message: rows[i]['message'],
        image: rows[i]['image'],
        link: rows[i]['link'],
        isRead: isRead,
      ));
    }
    return notifications;
  }

  DynamicLibrary _openOnLinux() {
    final libraryNextToScript =
        File('/home/maximilian/Documents/work/notifi/sqlite3.so');
    return DynamicLibrary.open(libraryNextToScript.path);
  }
}
