import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class HistoryMatch {
  const HistoryMatch({
    required this.matchId,
    required this.startTime,
    required this.leagueName,
    required this.team1Code,
    required this.team1Name,
    required this.team1Wins,
    required this.team2Code,
    required this.team2Name,
    required this.team2Wins,
    required this.bestOf,
  });

  final String matchId;
  final DateTime startTime;
  final String leagueName;
  final String team1Code;
  final String team1Name;
  final int team1Wins;
  final String team2Code;
  final String team2Name;
  final int team2Wins;
  final int bestOf;

  bool get team1Won => team1Wins > team2Wins;

  String get scoreText => '$team1Wins - $team2Wins';

  String get dateLabel {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[startTime.month - 1]} ${startTime.day}, ${startTime.year}';
  }
}

class ScheduleMatch {
  const ScheduleMatch({
    required this.matchId,
    required this.startTime,
    required this.blockName,
    required this.leagueName,
    required this.myCode,
    required this.myWins,
    required this.myOutcome,
    required this.myRecord,
    required this.oppCode,
    required this.oppName,
    required this.oppImage,
    required this.oppWins,
    required this.bestOf,
  });

  final String matchId;
  final DateTime startTime;
  final String blockName;
  final String leagueName;
  final String myCode;
  final int myWins;
  final String myOutcome; // 'win' | 'loss'
  final ({int wins, int losses}) myRecord;
  final String oppCode;
  final String oppName;
  final String oppImage;
  final int oppWins;
  final int bestOf;
}

class ScheduleTeam {
  const ScheduleTeam({
    required this.code,
    required this.name,
    required this.leagueName,
    required this.leagueSlug,
  });
  final String code;
  final String name;
  final String leagueName;
  final String leagueSlug;
}

class LeagueScheduleDatasource {
  LeagueScheduleDatasource(this._dio);
  final Dio _dio;

  /// Returns all unique teams that appeared in a league's schedule this season.
  Future<List<ScheduleTeam>> getAllTeamsForLeague(
    String leagueId,
    String leagueSlug,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$kEsportsApiBaseUrl/getSchedule',
      queryParameters: {'hl': 'en-US', 'leagueId': leagueId},
      options: Options(headers: {'x-api-key': kEsportsApiKey}),
    );

    final events = (response.data?['data']?['schedule']?['events'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final seen = <String>{};
    final teams = <ScheduleTeam>[];
    final leagueName = events.isNotEmpty
        ? ((events.first['league'] as Map<String, dynamic>?)?['name'] ?? leagueSlug)
        : leagueSlug;

    for (final event in events) {
      final matchTeams = (event['match']?['teams'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      for (final t in matchTeams) {
        final code = t['code'] as String? ?? '';
        final name = t['name'] as String? ?? '';
        if (code.isEmpty || code == 'TBD' || seen.contains(code)) continue;
        seen.add(code);
        teams.add(ScheduleTeam(
          code: code,
          name: name,
          leagueName: leagueName.toString(),
          leagueSlug: leagueSlug,
        ));
      }
    }
    return teams;
  }

  /// Returns all completed matches for a league (not filtered by team).
  Future<List<HistoryMatch>> getCompletedMatchesForLeague(
    String leagueId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$kEsportsApiBaseUrl/getSchedule',
      queryParameters: {'hl': 'en-US', 'leagueId': leagueId},
      options: Options(headers: {'x-api-key': kEsportsApiKey}),
    );

    final events = (response.data?['data']?['schedule']?['events'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final results = <HistoryMatch>[];

    for (final event in events) {
      if (event['state'] != 'completed') continue;
      final teams = (event['match']?['teams'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      if (teams.length < 2) continue;

      final t1 = teams[0];
      final t2 = teams[1];
      final r1 = t1['result'] as Map<String, dynamic>? ?? {};
      final r2 = t2['result'] as Map<String, dynamic>? ?? {};

      final leagueName =
          (event['league'] as Map<String, dynamic>?)?['name'] as String? ?? '';

      results.add(HistoryMatch(
        matchId: event['match']['id'] as String,
        startTime: DateTime.parse(event['startTime'] as String),
        leagueName: leagueName,
        team1Code: t1['code'] as String? ?? '',
        team1Name: t1['name'] as String? ?? '',
        team1Wins: (r1['gameWins'] as int?) ?? 0,
        team2Code: t2['code'] as String? ?? '',
        team2Name: t2['name'] as String? ?? '',
        team2Wins: (r2['gameWins'] as int?) ?? 0,
        bestOf: (event['match']?['strategy']?['count'] as int?) ?? 1,
      ));
    }

    results.sort((a, b) => b.startTime.compareTo(a.startTime));
    return results;
  }

  // Fetches all completed matches for a league and filters by team code.
  Future<(List<ScheduleMatch>, ({int wins, int losses})?)> getTeamResults(
    String leagueId,
    String teamCode,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$kEsportsApiBaseUrl/getSchedule',
      queryParameters: {'hl': 'en-US', 'leagueId': leagueId},
      options: Options(headers: {'x-api-key': kEsportsApiKey}),
    );

    final events = (response.data?['data']?['schedule']?['events'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final results = <ScheduleMatch>[];
    ({int wins, int losses})? latestRecord;

    for (final event in events) {
      if (event['state'] != 'completed') continue;
      final teams = (event['match']?['teams'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      if (teams.length < 2) continue;

      // Find which side is our team
      final myIdx = teams.indexWhere((t) => t['code'] == teamCode);
      if (myIdx == -1) continue;
      final oppIdx = 1 - myIdx;

      final my = teams[myIdx];
      final opp = teams[oppIdx];
      final myResult = my['result'] as Map<String, dynamic>? ?? {};
      final oppResult = opp['result'] as Map<String, dynamic>? ?? {};
      final myRecordRaw = my['record'] as Map<String, dynamic>?;

      if (myRecordRaw != null) {
        latestRecord = (
          wins: (myRecordRaw['wins'] as int?) ?? 0,
          losses: (myRecordRaw['losses'] as int?) ?? 0,
        );
      }

      results.add(ScheduleMatch(
        matchId: event['match']['id'] as String,
        startTime: DateTime.parse(event['startTime'] as String),
        blockName: event['blockName'] as String? ?? '',
        leagueName: (event['league'] as Map<String, dynamic>)['name'] as String,
        myCode: teamCode,
        myWins: (myResult['gameWins'] as int?) ?? 0,
        myOutcome: myResult['outcome'] as String? ?? '',
        myRecord: latestRecord ?? (wins: 0, losses: 0),
        oppCode: opp['code'] as String,
        oppName: opp['name'] as String,
        oppImage: opp['image'] as String? ?? '',
        oppWins: (oppResult['gameWins'] as int?) ?? 0,
        bestOf: (event['match']?['strategy']?['count'] as int?) ?? 1,
      ));
    }

    // Most recent first
    results.sort((a, b) => b.startTime.compareTo(a.startTime));
    return (results, latestRecord);
  }
}
