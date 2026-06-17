import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';

class FavoritesLocalDatasource {
  FavoritesLocalDatasource({AppDatabase? database})
      : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<Set<String>> loadAll() async {
    final db = await _db.database;
    final rows = await db.query('favorites');
    return rows.map((r) => r['id'] as String).toSet();
  }

  Future<void> insert(String id) async {
    final db = await _db.database;
    await db.insert(
      'favorites',
      {'id': id, 'created_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}
