import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../services/notification_scheduler.dart';

enum AppScreen { home, history, teams, favorites, profile }

enum TeamTab { roster, stats, results, next }

class AppProvider extends ChangeNotifier {
  AppProvider(this._favoritesRepository);

  final FavoritesRepository _favoritesRepository;

  AppScreen _screen = AppScreen.home;
  TeamTab _teamTab = TeamTab.roster;
  Set<String> _favorites = {};
  bool _darkMode = true;

  AppScreen get screen => _screen;
  TeamTab get teamTab => _teamTab;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool get darkMode => _darkMode;

  /// Loads persisted favorites from the repository. Call once at startup.
  Future<void> init() async {
    _favorites = await _favoritesRepository.loadAll();
    notifyListeners();
  }

  void goHome() {
    _screen = AppScreen.home;
    notifyListeners();
  }

  void goHistory() {
    _screen = AppScreen.history;
    notifyListeners();
  }

  void goTeams() {
    _screen = AppScreen.teams;
    notifyListeners();
  }

  void goFavorites() {
    _screen = AppScreen.favorites;
    notifyListeners();
  }

  void goProfile() {
    _screen = AppScreen.profile;
    notifyListeners();
  }

  void setTeamTab(TeamTab tab) {
    _teamTab = tab;
    notifyListeners();
  }

  /// Optimistic toggle: updates state immediately and persists in background.
  void toggleFavorite(String teamId) {
    if (_favorites.contains(teamId)) {
      _favorites.remove(teamId);
      unawaited(_favoritesRepository.remove(teamId));
    } else {
      _favorites.add(teamId);
      unawaited(_favoritesRepository.add(teamId));
    }
    notifyListeners();
    unawaited(_syncFavoritesForNotifications());
  }

  Future<void> _syncFavoritesForNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    // Persist favorites list for background task (different key format)
    await prefs.setStringList('favorites', _favorites.toList());
    final notifStart = prefs.getBool('notif_match_start') ?? true;
    final notifEnd = prefs.getBool('notif_match_end') ?? true;
    if (!notifStart && !notifEnd) return;
    await NotificationScheduler.instance.refresh(
      favCodes: _favorites,
      notifStart: notifStart,
      notifEnd: notifEnd,
    );
  }

  bool isFavorite(String teamId) => _favorites.contains(teamId);

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }
}
