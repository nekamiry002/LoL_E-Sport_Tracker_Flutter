import 'package:flutter/material.dart';

enum AppScreen { home, favorites, profile }

enum TeamTab { roster, stats, results, next }

class AppProvider extends ChangeNotifier {
  AppScreen _screen = AppScreen.home;
  TeamTab _teamTab = TeamTab.roster;
  final Set<String> _favorites = {'t1', 'g2'};
  bool _darkMode = true;

  AppScreen get screen => _screen;
  TeamTab get teamTab => _teamTab;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool get darkMode => _darkMode;

  void goHome() {
    _screen = AppScreen.home;
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

  void toggleFavorite(String teamId) {
    if (_favorites.contains(teamId)) {
      _favorites.remove(teamId);
    } else {
      _favorites.add(teamId);
    }
    notifyListeners();
  }

  bool isFavorite(String teamId) => _favorites.contains(teamId);

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }
}
