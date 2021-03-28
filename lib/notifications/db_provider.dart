import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// import 'package:sqlite3/sqlite3.dart';

import 'notification.dart';

class DBProvider {
  DBProvider(this.dbPath);

  final String _table = 'notifications';
  final String dbPath;
  Database _db;

  Future<Database> initDB() async {
    if (_db != null) {
      return _db;
    }

    return _db = await openDatabase(
        // Set the path to the database. Note: Using the `join` function
        //from the `path` package is best practice to ensure the path is
        //correctly constructed for each platform.
        join(await getDatabasesPath(), dbPath),
        onCreate: (Database db, int version) {
      return db.execute('''
        CREATE TABLE IF NOT EXISTS $_table (
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
    return db.rawInsert('''
        INSERT INTO $_table 
          (UUID, title, time, message, image, link)
        VALUES 
          (?, ?, ?, ?, ?, ?)
        ''', <dynamic>[
      notification.uuid,
      notification.title,
      notification.time,
      notification.message,
      notification.image,
      notification.link,
    ]);
  }

  Future<int> delete(int id) async {
    final Database db = await initDB();
    return db.delete(_table, where: '_id = ?', whereArgs: <int>[id]);
  }

  Future<int> deleteAll() async {
    final Database db = await initDB();
    return db.rawDelete('DELETE FROM $_table');
  }

  Future<int> markRead(int id, {bool isRead}) async {
    int read = 0;
    if (isRead) read = 1;
    final Database db = await initDB();
    return db
        .rawUpdate('UPDATE $_table SET read=? WHERE _id=?', <int>[read, id]);
  }

  Future<int> markAllRead() async {
    final Database db = await initDB();
    return db.rawUpdate('UPDATE $_table SET read=?', <int>[1]);
  }

  Future<List<NotificationUI>> getAll() async {
    final List<NotificationUI> notifications =
        List<NotificationUI>.empty(growable: true);
    final Database db = await initDB();

    // language=SQLite
    final List<Map<String, dynamic>> rows = await db.rawQuery('''
    SELECT * FROM notifications ORDER BY _id DESC''');

    for (int i = 0; i < rows.length; i++) {
      bool isRead = false;
      if (rows[i]['read'] == 1) {
        isRead = true;
      }

      notifications.add(NotificationUI(
        rows[i]['_id'] as int,
        rows[i]['title'] as String,
        rows[i]['time'] as String,
        rows[i]['UUID'] as String,
        rows[i]['message'] as String,
        rows[i]['image'] as String,
        rows[i]['link'] as String,
        read: isRead,
      ));
    }
    return notifications;
  }
}
