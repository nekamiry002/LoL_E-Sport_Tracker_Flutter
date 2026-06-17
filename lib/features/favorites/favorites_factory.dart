// On web (no dart:io): returns FavoritesRepositoryMemory.
// On native targets:   returns FavoritesRepositoryImpl (sqflite).
export 'favorites_factory_stub.dart'
    if (dart.library.io) 'favorites_factory_io.dart';
