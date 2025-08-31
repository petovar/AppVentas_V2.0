import 'package:sqflite/sqflite.dart';

import 'sqlite_handler.dart';

class DatabaseHelper {
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  SqliteHandler mSqliteHandler = SqliteHandler();
  static final columnId = 'idx';
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row, String table) async {
    Database db = await mSqliteHandler.getDb();
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await mSqliteHandler.getDb();
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount(String table) async {
    Database db = await mSqliteHandler.getDb();
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $table'),
    );
  }

  // We are using a bare database API (no type safety) for simplicity.
  // In a real app, you'd likely create a class to model the data and use
  // higher-level APIs like this:
  // Future<List<Todo>> todos() async {
  //   final List<Map<String, dynamic>> maps = await db.query('todos');
  //   return List.generate(maps.length, (i) {
  //     return Todo(
  //       id: maps[i]['id'],
  //       title: maps[i]['title'],
  //       completed: maps[i]['completed'] == 1,
  //     );
  //   });
  // }

  // All data is banked as Maps.
  Future<int> update(Map<String, dynamic> row, String table) async {
    Database db = await mSqliteHandler.getDb();
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id, String table) async {
    Database db = await mSqliteHandler.getDb();
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
