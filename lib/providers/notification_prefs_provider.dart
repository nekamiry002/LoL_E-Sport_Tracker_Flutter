import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefsProvider extends ChangeNotifier {
  static const _keyMatchStart = 'notif_match_start';
  static const _keyMatchEnd = 'notif_match_end';
  static const _keyLiveUpdates = 'notif_live_updates';

  bool matchStart = true;
  bool matchEnd = true;
  bool liveUpdates = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    matchStart = prefs.getBool(_keyMatchStart) ?? true;
    matchEnd = prefs.getBool(_keyMatchEnd) ?? true;
    liveUpdates = prefs.getBool(_keyLiveUpdates) ?? false;
    notifyListeners();
  }

  Future<void> save({
    required bool matchStart,
    required bool matchEnd,
    required bool liveUpdates,
  }) async {
    this.matchStart = matchStart;
    this.matchEnd = matchEnd;
    this.liveUpdates = liveUpdates;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMatchStart, matchStart);
    await prefs.setBool(_keyMatchEnd, matchEnd);
    await prefs.setBool(_keyLiveUpdates, liveUpdates);
  }
}
