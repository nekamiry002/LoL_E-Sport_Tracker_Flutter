// Native target: favorites persisted in SQLite via sqflite.
import 'domain/repositories/favorites_repository.dart';
import 'data/repositories/favorites_repository_impl.dart';

FavoritesRepository createFavoritesRepository() =>
    FavoritesRepositoryImpl();
