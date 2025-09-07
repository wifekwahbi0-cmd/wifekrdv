import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.DB_NAME);
    var db = await openDatabase(path, version: AppConstants.DB_VERSION, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER,
        birth_date TEXT,
        phone TEXT,
        diagnosis TEXT,
        notes TEXT
      )
    """);

    await db.execute("""
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        duration INTEGER DEFAULT 45,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (child_id) REFERENCES children(id)
      )
    """);

    await db.execute("""
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        goals TEXT,
        progress TEXT,
        notes TEXT,
        report_date TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )
    """);
  }
}
