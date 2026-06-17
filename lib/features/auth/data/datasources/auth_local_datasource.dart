import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';

class AuthLocalDatasource {
  AuthLocalDatasource({AppDatabase? database})
      : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  static const _sessionKey = 'current_user';

  Future<int?> getCurrentUserId() async {
    final db = await _db.database;
    final rows = await db.query('sessions',
        where: 'key = ?', whereArgs: [_sessionKey]);
    return rows.isEmpty ? null : rows.first['user_id'] as int;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await _db.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> emailExists(String email) async {
    final db = await _db.database;
    final rows =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    return rows.isNotEmpty;
  }

  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final db = await _db.database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> findByEmailAndPassword(
      String email, String hashedPassword) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updatePassword(int id, String hashedPassword) async {
    final db = await _db.database;
    await db.update(
      'users',
      {'password': hashedPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createUser({
    required String username,
    required String email,
    required String hashedPassword,
    required int createdAt,
  }) async {
    final db = await _db.database;
    return db.insert('users', {
      'username': username,
      'email': email,
      'password': hashedPassword,
      'created_at': createdAt,
    });
  }

  Future<void> updateUser(int id, {String? username, String? email}) async {
    final db = await _db.database;
    final fields = <String, dynamic>{
      'username': username,
      'email': email,
    }..removeWhere((_, v) => v == null);
    if (fields.isEmpty) return;
    await db.update('users', fields, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveSession(int userId) async {
    final db = await _db.database;
    await db.insert(
      'sessions',
      {'key': _sessionKey, 'user_id': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearSession() async {
    final db = await _db.database;
    await db.delete('sessions', where: 'key = ?', whereArgs: [_sessionKey]);
  }
}
