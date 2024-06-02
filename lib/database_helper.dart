import 'package:schedule_builder/task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
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
    String path = join(await getDatabasesPath(), 'schedule.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE tasks(image TEXT, text TEXT, isDone INTEGER, isHighlighted INTEGER, showCancelIcon INTEGER, showCancelText INTEGER)",
        );
        db.execute(
          "CREATE TABLE appBar(imagePath TEXT, title TEXT)",
        );
        db.insert('appBar', {'imagePath': '', 'title': 'My Schedule'});
      },
    );
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'text = ?',
      whereArgs: [task.text],
    );
  }

  Future<void> deleteAllTasks() async {
    final db = await database;
    await db.delete('tasks');
  }

  Future<Map<String, String>> getAppBarData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('appBar');
    if (result.isNotEmpty) {
      return {
        'imagePath': result[0]['imagePath'] ?? '',
        'title': result[0]['title'] ?? 'My Schedule',
      };
    }
    return {'imagePath': '', 'title': 'My Schedule'};
  }

  Future<void> updateAppBarData(String imagePath, String title) async {
    final db = await database;
    await db.update(
      'appBar',
      {'imagePath': imagePath, 'title': title},
    );
  }

}
