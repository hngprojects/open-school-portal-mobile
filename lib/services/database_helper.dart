import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nfc_tag TEXT NOT NULL,
          type TEXT NOT NULL, 
          class_id TEXT,
          timestamp TEXT NOT NULL
        )
      ''');
      },
    );
  }

  Future<int> insertAttendance(
    String tag,
    String type, {
    String? classId,
  }) async {
    final db = await instance.database;
    return await db.insert('attendance', {
      'nfc_tag': tag,
      'type': type,
      'class_id': classId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllUnsynced() async {
    final db = await instance.database;
    return await db.query('attendance');
  }

  Future<int> deleteRecord(int id) async {
    final db = await instance.database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}
