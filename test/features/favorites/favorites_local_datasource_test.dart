import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lol_esport_tracker/core/database/app_database.dart';
import 'package:lol_esport_tracker/features/favorites/data/datasources/favorites_local_datasource.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite with FFI so tests run on desktop (Windows/macOS/Linux).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('FavoritesLocalDatasource', () {
    late AppDatabase db;
    late FavoritesLocalDatasource datasource;

    setUp(() {
      db = AppDatabase.forTest();
      datasource = FavoritesLocalDatasource(database: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('loadAll returns empty set on a fresh database', () async {
      final result = await datasource.loadAll();
      expect(result, isEmpty);
    });

    test('insert adds a favorite and loadAll returns it', () async {
      await datasource.insert('t1');
      final result = await datasource.loadAll();
      expect(result, contains('t1'));
    });

    test('insert multiple favorites', () async {
      await datasource.insert('t1');
      await datasource.insert('g2');
      await datasource.insert('fnc');
      final result = await datasource.loadAll();
      expect(result, containsAll(['t1', 'g2', 'fnc']));
      expect(result.length, 3);
    });

    test('insert ignores duplicate ids', () async {
      await datasource.insert('t1');
      await datasource.insert('t1');
      final result = await datasource.loadAll();
      expect(result.where((id) => id == 't1').length, 1);
    });

    test('delete removes an existing favorite', () async {
      await datasource.insert('t1');
      await datasource.delete('t1');
      final result = await datasource.loadAll();
      expect(result, isNot(contains('t1')));
    });

    test('delete on non-existing id does not throw', () async {
      await expectLater(datasource.delete('nonexistent'), completes);
    });

    test('loadAll returns only remaining items after delete', () async {
      await datasource.insert('t1');
      await datasource.insert('g2');
      await datasource.delete('t1');
      final result = await datasource.loadAll();
      expect(result, contains('g2'));
      expect(result, isNot(contains('t1')));
    });
  });
}
