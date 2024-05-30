import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_todo_app/models/task_model.dart';

class DatabaseServices {
  DatabaseServices._constructor();

  static final DatabaseServices instance = DatabaseServices._constructor();
  static Database? _db;
  final _taskTableName = 'tasks';
  final _taskIdColumnName = 'id';
  final _taskContentColumnName = 'content';
  final _taskStatusColumnName = 'status';

  Future<Database> get getDatabase async {
    if (_db != null) return _db!;
    _db = await createDatabase();
    return _db!;
  }

  Future<Database> createDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    // final databasePath = join(databaseDirPath, "master_db.db");
    final databasePath = join(databaseDirPath, "master_db2.db");
    final database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_taskTableName(
        $_taskIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        $_taskContentColumnName TEXT NOT NULL,
        $_taskStatusColumnName INTEGER NOT NULL
        )
        ''');
      },
    );
    return database;
  }

  Future<void> addTask(String content) async {
    final db = await getDatabase;
    await db.insert(_taskTableName, {
      _taskContentColumnName: content,
      _taskStatusColumnName: 0,
    });
    log("task item inserted successfully!");
  }

  Future<List<TaskModel>> getAllTasks() async {
    try {
      final db = await getDatabase;
      final data = await db.query(_taskTableName) as List<Map<String, dynamic>>;
      log("this is queried data: $data");
      return data.map((task) => TaskModel.fromMap(task)).toList();
    } catch (e) {
      log("error while fetching all tasks>>>>>>>>>> $e");
      return [];
    }
  }

  Future<void> updateStatus(int status, int id) async {
    try {
      final db = await getDatabase;
      await db.update(
        _taskTableName,
        {
          _taskStatusColumnName: status,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      log("task item's status updated successfully!(id is $status)");
    } catch (e) {
      log("error while updating status>>>>>>> $e");
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final db = await getDatabase;
      await db.delete(_taskTableName, where: 'id = ?', whereArgs: [id]);
      log("task item deleted successfully!");
    } catch (e) {
      log("error while deleting task>>>>>>> $e");
    }
  }
}
