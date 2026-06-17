import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Web implementation: persists favorites in browser localStorage.
class FavoritesRepositoryPrefs implements FavoritesRepository {
  static const _key = 'favorites';
  static const _defaultFavorites = ['t1', 'g2'];

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<Set<String>> loadAll() async {
    final prefs = await _prefs;
    final stored = prefs.getStringList(_key);
    // First launch: seed defaults
    if (stored == null) {
      await prefs.setStringList(_key, _defaultFavorites);
      return Set.of(_defaultFavorites);
    }
    return stored.toSet();
  }

  @override
  Future<void> add(String id) async {
    final current = await loadAll();
    current.add(id);
    final prefs = await _prefs;
    await prefs.setStringList(_key, current.toList());
  }

  @override
  Future<void> remove(String id) async {
    final current = await loadAll();
    current.remove(id);
    final prefs = await _prefs;
    await prefs.setStringList(_key, current.toList());
  }
}
