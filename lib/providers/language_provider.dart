import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _key = 'selected_language';

  String _selected = 'English';
  String get selected => _selected;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _selected = prefs.getString(_key) ?? 'English';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_selected == language) return;
    _selected = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language);
  }
}
