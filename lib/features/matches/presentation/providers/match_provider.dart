import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../data/mock_data.dart';
import '../../data/datasources/league_schedule_datasource.dart';
import '../../domain/entities/match.dart';
import '../../domain/usecases/get_matches.dart';
import '../adapters/match_adapter.dart';

enum MatchesStatus { initial, loading, success, failure }

class MatchProvider extends ChangeNotifier {
  MatchProvider(this._getMatches, {LeagueScheduleDatasource? scheduleDatasource})
      : _scheduleDatasource = scheduleDatasource;

  final GetMatches _getMatches;
  final LeagueScheduleDatasource? _scheduleDatasource;

  List<MatchDisplayData> _displayMatches = [];
  final Map<String, TeamData> teamRegistry = {};
  MatchesStatus _status = MatchesStatus.initial;
  String? _error;
  String _leagueFilter = 'ALL';
  List<String> _availableLeagues = [];

  List<MatchDisplayData> get displayMatches => _leagueFilter == 'ALL'
      ? _displayMatches
      : _displayMatches
          .where((m) => m.league == _leagueFilter)
          .toList();

  MatchesStatus get status => _status;
  String? get error => _error;
  String get leagueFilter => _leagueFilter;
  List<String> get availableLeagues => _availableLeagues;

  void setFilter(String filter) {
    _leagueFilter = filter;
    notifyListeners();
  }

  Future<void> fetchMatches({List<String>? leagueIds}) async {
    _status = MatchesStatus.loading;
    _error = null;
    notifyListeners();

    // Browsers block CORS requests to lolesports.com — use mock data on web.
    if (kIsWeb) {
      _displayMatches = MockData.allMatches;
      _availableLeagues =
          _displayMatches.map((m) => m.league).toSet().toList();
      _status = MatchesStatus.success;
      notifyListeners();
      return;
    }

    try {
      final matches = await _getMatches(leagueIds: leagueIds);
      teamRegistry.clear();
      _displayMatches = adaptMatches(matches, teamRegistry);
      _availableLeagues = _buildLeagueList(matches);
      if (_leagueFilter != 'ALL' &&
          !_availableLeagues.contains(_leagueFilter)) {
        _leagueFilter = 'ALL';
      }
      _status = MatchesStatus.success;
      notifyListeners();

      // Fetch all season teams in background to fill registry beyond upcoming matches.
      _fetchAllSeasonTeams();
    } catch (e) {
      _error = e.toString();
      _status = MatchesStatus.failure;
      notifyListeners();
    }
  }

  Future<void> _fetchAllSeasonTeams() async {
    final ds = _scheduleDatasource;
    if (ds == null) return;
    for (final entry in kLeagueIds.entries) {
      try {
        final teams = await ds.getAllTeamsForLeague(entry.value, entry.key);
        var changed = false;
        for (final t in teams) {
          if (!teamRegistry.containsKey(t.code)) {
            teamRegistry[t.code] = teamDataFromApi(
              code: t.code,
              name: t.name,
              leagueSlug: t.leagueSlug,
              apiId: '',
            );
            changed = true;
          }
        }
        if (changed) notifyListeners();
      } catch (_) {
        // Skip failed leagues silently
      }
    }
  }

  List<String> _buildLeagueList(List<Match> matches) {
    final seen = <String>{};
    final result = <String>[];
    for (final m in matches) {
      if (seen.add(m.leagueName)) result.add(m.leagueName);
    }
    return result;
  }

  TeamData teamFor(String code) =>
      teamRegistry[code] ?? MockData.team(code);
}
