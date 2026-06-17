import 'package:flutter/foundation.dart';

import '../../../../data/mock_data.dart';
import '../../domain/entities/match.dart';
import '../../domain/usecases/get_matches.dart';
import '../adapters/match_adapter.dart';

enum MatchesStatus { initial, loading, success, failure }

class MatchProvider extends ChangeNotifier {
  MatchProvider(this._getMatches);

  final GetMatches _getMatches;

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
    } catch (e) {
      _error = e.toString();
      _status = MatchesStatus.failure;
    }

    notifyListeners();
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
