import 'package:flutter/foundation.dart';

import '../../data/datasources/league_schedule_datasource.dart';
import '../../../../core/constants/api_constants.dart';

enum ScheduleStatus { initial, loading, success, failure }

class TeamScheduleState {
  const TeamScheduleState({
    this.results = const [],
    this.record,
    this.status = ScheduleStatus.initial,
    this.error,
  });

  final List<ScheduleMatch> results;
  final ({int wins, int losses})? record;
  final ScheduleStatus status;
  final String? error;
}

class TeamScheduleProvider extends ChangeNotifier {
  TeamScheduleProvider(this._datasource);

  final LeagueScheduleDatasource _datasource;
  final Map<String, TeamScheduleState> _cache = {};

  TeamScheduleState stateFor(String teamCode) =>
      _cache[teamCode] ?? const TeamScheduleState();

  Future<void> fetchForTeam(String teamCode, {String? leagueId}) async {
    if (teamCode.isEmpty) return;
    final existing = _cache[teamCode];
    if (existing?.status == ScheduleStatus.success) return;

    _cache[teamCode] = TeamScheduleState(status: ScheduleStatus.loading);
    notifyListeners();

    try {
      // Try all known leagues if no specific one given; pick first with results.
      final leaguesToTry = leagueId != null ? [leagueId] : kLeagueIds.values.toList();
      List<ScheduleMatch> found = [];
      ({int wins, int losses})? record;

      for (final lid in leaguesToTry) {
        final (matches, rec) = await _datasource.getTeamResults(lid, teamCode);
        if (matches.isNotEmpty) {
          found = matches;
          record = rec;
          break;
        }
      }

      _cache[teamCode] = TeamScheduleState(
        results: found,
        record: record,
        status: ScheduleStatus.success,
      );
    } catch (e) {
      _cache[teamCode] = TeamScheduleState(
        status: ScheduleStatus.failure,
        error: e.toString(),
      );
    }

    notifyListeners();
  }
}
