import 'domain/repositories/favorites_repository.dart';
import 'data/repositories/favorites_repository_prefs.dart';

FavoritesRepository createFavoritesRepository() =>
    FavoritesRepositoryPrefs();
