import '../../domain/repositories/favorites_repository.dart';

/// In-memory implementation used on web and in unit tests.
class FavoritesRepositoryMemory implements FavoritesRepository {
  FavoritesRepositoryMemory({Set<String>? seed})
      : _data = Set.of(seed ?? {'t1', 'g2'});

  final Set<String> _data;

  @override
  Future<Set<String>> loadAll() async => Set.of(_data);

  @override
  Future<void> add(String id) async => _data.add(id);

  @override
  Future<void> remove(String id) async => _data.remove(id);
}
