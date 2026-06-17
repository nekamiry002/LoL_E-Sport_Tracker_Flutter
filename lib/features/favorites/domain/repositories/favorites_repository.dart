abstract interface class FavoritesRepository {
  Future<Set<String>> loadAll();
  Future<void> add(String id);
  Future<void> remove(String id);
}
