import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'strm_tasks.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT,
        isSynced    INTEGER DEFAULT 0,
        createdAt   TEXT    NOT NULL
      )
    ''');
  }

  // INSERT a new task
  static Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ all tasks
  static Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'id DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  // READ only unsynced tasks (for the sync feature)
  static Future<List<Task>> getUnsyncedTasks() async {
    final db = await database;
    final maps = await db.query('tasks', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  // UPDATE a task's synced status
  static Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update('tasks', {'isSynced': 1},
      where: 'id = ?', whereArgs: [id]);
  }

  // DELETE a task
  static Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}