import 'package:schedule_builder/task.dart';
import 'package:schedule_builder/schedulemodel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await initializeDatabase();
    return _db!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'schedules.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE schedules(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );
        db.execute(
          "CREATE TABLE tasks(image TEXT, text TEXT, isDone INTEGER, isHighlighted INTEGER, showCancelIcon INTEGER, showCancelText INTEGER, scheduleId INTEGER, FOREIGN KEY(scheduleId) REFERENCES schedules(id) ON DELETE CASCADE)",
        );
        db.execute(
          "CREATE TABLE appBar(imagePath TEXT, title TEXT, scheduleId INTEGER, FOREIGN KEY(scheduleId) REFERENCES schedules(id) ON DELETE CASCADE)",
        );
        db.insert('schedules', {'name': 'My Schedule'});
        db.insert('appBar', {'imagePath': '', 'title': 'My Schedule', 'scheduleId': 1});
      },
      onOpen: (db) {
        print("Database opened");
      },
    );
  }

  Future<void> insertTask(Task task, int scheduleId) async {
    final db = await database;
    await db.insert(
      'tasks',
      {...task.toMap(), 'scheduleId': scheduleId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks(int scheduleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', where: 'scheduleId = ?', whereArgs: [scheduleId]);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task, int scheduleId) async {
    final db = await database;
    await db.update(
      'tasks',
      //task.toMap(),
      {...task.toMap(), 'scheduleId': scheduleId},
      where: 'text = ?',
      whereArgs: [task.text],
    );
  }

  Future<void> deleteAllTasks(int scheduleId) async {
    final db = await database;
    await db.delete('tasks', where: 'scheduleId = ?', whereArgs: [scheduleId]);
  }

  Future<Map<String, String>> getAppBarData(int scheduleId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('appBar', where: 'scheduleId = ?', whereArgs: [scheduleId]);
    if (result.isNotEmpty) {
      return {
        'imagePath': result[0]['imagePath'] ?? '',
        'title': result[0]['title'] ?? 'My Schedule',
      };
    }
    return {'imagePath': '', 'title': 'My Schedule'};
  }

  Future<void> updateAppBarData(String imagePath, String title, int scheduleId) async {
    final db = await database;
    await db.update(
      'appBar',
      {'imagePath': imagePath, 'title': title}, where: 'scheduleId = ?', whereArgs: [scheduleId]
    );
  }

  Future<int> createSchedule(String name) async {
    final db = await database;
    print('creating new schedule $name');
    return await db.insert('schedules', {'name': name}, conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  Future<List<ScheduleModel>> getSchedules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return List.generate(maps.length, (i) {
      return ScheduleModel.fromMap(
        maps[i]);
    });
  }

  Future<void> deleteSchedule(int id) async {
    final db = await database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }


}
