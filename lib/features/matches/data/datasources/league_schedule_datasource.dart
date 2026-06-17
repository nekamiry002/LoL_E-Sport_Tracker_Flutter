import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

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

class LeagueScheduleDatasource {
  LeagueScheduleDatasource(this._dio);
  final Dio _dio;

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
