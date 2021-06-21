import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/utils/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider(this.dbPath, {this.templateDB: false});

  final String _table = 'notifications';
  final String dbPath;
  Database _db;
  bool templateDB;

  Future<Database> initDB() async {
    if (_db != null) {
      return _db;
    }

    String path;
    if (templateDB) {
      // write template db asset to file in app
      final Directory directory = await getApplicationDocumentsDirectory();
      final ByteData data = await rootBundle.load('template.db');
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      path = join(directory.path, 'local.db');
      await File(path).writeAsBytes(bytes);
    } else {
      Directory dir;
      if (Platform.isAndroid) {
        dir = await getApplicationSupportDirectory();
      } else {
        dir = await getLibraryDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();
      path = join(join(dir.path, 'notifi/'), dbPath);
    }
    L.i('DB path: $path');

    return _db = await openDatabase(path, onCreate: (Database db, int version) {
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

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
    SELECT * FROM notifications ORDER BY _id DESC''');

    for (int i = 0; i < rows.length; i++) {
      bool isRead = false;
      if (rows[i]['read'] == 1) {
        isRead = true;
      }

      notifications.add(NotificationUI(
        id: rows[i]['_id'] as int,
        uuid: rows[i]['UUID'] as String,
        time: rows[i]['time'] as String,
        title: rows[i]['title'] as String,
        message: rows[i]['message'] as String,
        image: rows[i]['image'] as String,
        link: rows[i]['link'] as String,
        read: isRead,
      ));
    }
    return notifications;
  }
}
