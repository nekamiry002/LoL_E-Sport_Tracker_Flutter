import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._({bool isTest = false}) : _isTest = isTest;

  static final AppDatabase instance = AppDatabase._();

  factory AppDatabase.forTest() => AppDatabase._(isTest: true);

  final bool _isTest;
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    if (_isTest) {
      return openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: _onCreate,
      );
    }
    final path = join(await getDatabasesPath(), 'lol_tracker.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id         TEXT    PRIMARY KEY,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        username   TEXT    NOT NULL,
        email      TEXT    UNIQUE NOT NULL,
        password   TEXT    NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions (
        key     TEXT    PRIMARY KEY,
        user_id INTEGER NOT NULL
      )
    ''');
    if (!_isTest) {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final id in ['t1', 'g2']) {
        await db.insert('favorites', {'id': id, 'created_at': now});
      }
    }
  }

  // Migration v1 → v2: add auth tables.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          username   TEXT    NOT NULL,
          email      TEXT    UNIQUE NOT NULL,
          password   TEXT    NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sessions (
          key     TEXT    PRIMARY KEY,
          user_id INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
