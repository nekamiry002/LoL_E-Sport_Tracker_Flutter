import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';

/// SQLite implementation — Android, iOS, macOS, Windows, Linux.
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({FavoritesLocalDatasource? datasource})
      : _datasource = datasource ?? FavoritesLocalDatasource();

  final FavoritesLocalDatasource _datasource;

  @override
  Future<Set<String>> loadAll() => _datasource.loadAll();

  @override
  Future<void> add(String id) => _datasource.insert(id);

  @override
  Future<void> remove(String id) => _datasource.delete(id);
}
