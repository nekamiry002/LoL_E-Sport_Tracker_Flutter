import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../data/datasources/league_schedule_datasource.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._datasource);

  final LeagueScheduleDatasource _datasource;

  List<HistoryMatch> _matches = [];
  HistoryStatus _status = HistoryStatus.initial;
  String? _error;

  List<HistoryMatch> get matches => _matches;
  HistoryStatus get status => _status;
  String? get error => _error;

  List<String> get availableLeagues {
    final seen = <String>{};
    return _matches.map((m) => m.leagueName).where(seen.add).toList();
  }

  Future<void> fetchHistory() async {
    if (_status == HistoryStatus.loading) return;
    _status = HistoryStatus.loading;
    _error = null;
    notifyListeners();

    final all = <HistoryMatch>[];
    for (final entry in kLeagueIds.entries) {
      try {
        final results = await _datasource.getCompletedMatchesForLeague(entry.value);
        all.addAll(results);
      } catch (_) {
        // Skip failed leagues silently
      }
    }

    all.sort((a, b) => b.startTime.compareTo(a.startTime));
    _matches = all;
    _status = HistoryStatus.success;
    notifyListeners();
  }
}
