import 'package:flutter_test/flutter_test.dart';
import 'package:lol_esport_tracker/features/favorites/data/repositories/favorites_repository_memory.dart';
import 'package:lol_esport_tracker/providers/app_provider.dart';

void main() {
  group('AppProvider', () {
    late AppProvider provider;

    setUp(() async {
      provider = AppProvider(FavoritesRepositoryMemory(seed: {}));
      await provider.init();
    });

    test('starts on home screen', () {
      expect(provider.screen, AppScreen.home);
    });

    test('goHistory switches to history screen', () {
      provider.goHistory();
      expect(provider.screen, AppScreen.history);
    });

    test('goTeams switches to teams screen', () {
      provider.goTeams();
      expect(provider.screen, AppScreen.teams);
    });

    test('goFavorites switches to favorites screen', () {
      provider.goFavorites();
      expect(provider.screen, AppScreen.favorites);
    });

    test('goHome resets to home after navigation', () {
      provider.goHistory();
      provider.goHome();
      expect(provider.screen, AppScreen.home);
    });

    test('toggleFavorite adds a team', () {
      provider.toggleFavorite('t1');
      expect(provider.isFavorite('t1'), isTrue);
    });

    test('toggleFavorite removes a team that was already favorited', () {
      provider.toggleFavorite('t1');
      provider.toggleFavorite('t1');
      expect(provider.isFavorite('t1'), isFalse);
    });

    test('isFavorite returns false for unknown team', () {
      expect(provider.isFavorite('unknown'), isFalse);
    });

    test('favorites are loaded from repository on init', () async {
      final seededProvider = AppProvider(
        FavoritesRepositoryMemory(seed: {'geng', 'fnc'}),
      );
      await seededProvider.init();

      expect(seededProvider.isFavorite('geng'), isTrue);
      expect(seededProvider.isFavorite('fnc'), isTrue);
      expect(seededProvider.isFavorite('t1'), isFalse);
    });

    test('notifies listeners when toggling favorite', () {
      int callCount = 0;
      provider.addListener(() => callCount++);

      provider.toggleFavorite('kt');

      expect(callCount, 1);
    });

    test('notifies listeners on screen change', () {
      int callCount = 0;
      provider.addListener(() => callCount++);

      provider.goTeams();
      provider.goFavorites();

      expect(callCount, 2);
    });

    test('favorites set is unmodifiable', () {
      expect(
        () => provider.favorites.add('x'),
        throwsUnsupportedError,
      );
    });
  });
}
