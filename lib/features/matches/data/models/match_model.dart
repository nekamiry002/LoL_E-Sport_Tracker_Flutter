import '../../domain/entities/match.dart';

class MatchModel {
  const MatchModel({
    required this.id,
    required this.startTime,
    required this.state,
    required this.leagueName,
    required this.leagueSlug,
    required this.leagueImageUrl,
    required this.team1Name,
    required this.team1Code,
    required this.team1ApiId,
    required this.team1ImageUrl,
    required this.team1Wins,
    required this.team2Name,
    required this.team2Code,
    required this.team2ApiId,
    required this.team2ImageUrl,
    required this.team2Wins,
    required this.bestOf,
  });

  final String id;
  final DateTime startTime;
  final MatchState state;
  final String leagueName;
  final String leagueSlug;
  final String leagueImageUrl;
  final String team1Name;
  final String team1Code;
  final String team1ApiId;
  final String team1ImageUrl;
  final int team1Wins;
  final String team2Name;
  final String team2Code;
  final String team2ApiId;
  final String team2ImageUrl;
  final int team2Wins;
  final int bestOf;

  factory MatchModel.fromJson(Map<String, dynamic> event) {
    final league = event['league'] as Map<String, dynamic>;
    final match = event['match'] as Map<String, dynamic>;
    final teams = event['matchTeams'] as List<dynamic>;
    final t1 = teams[0] as Map<String, dynamic>;
    final t2 = teams[1] as Map<String, dynamic>;
    final r1 = t1['result'] as Map<String, dynamic>? ?? {};
    final r2 = t2['result'] as Map<String, dynamic>? ?? {};

    // id format is "matchId:teamId" — extract the real team id
    String extractTeamId(String raw) =>
        raw.contains(':') ? raw.split(':').last : raw;

    return MatchModel(
      id: match['id'] as String,
      startTime: DateTime.parse(event['startTime'] as String),
      state: _parseState(event['state'] as String),
      leagueName: league['name'] as String,
      leagueSlug: league['slug'] as String,
      leagueImageUrl: league['image'] as String? ?? '',
      team1Name: t1['name'] as String,
      team1Code: t1['code'] as String,
      team1ApiId: extractTeamId(t1['id'] as String),
      team1ImageUrl: t1['image'] as String? ?? '',
      team1Wins: (r1['gameWins'] as int?) ?? 0,
      team2Name: t2['name'] as String,
      team2Code: t2['code'] as String,
      team2ApiId: extractTeamId(t2['id'] as String),
      team2ImageUrl: t2['image'] as String? ?? '',
      team2Wins: (r2['gameWins'] as int?) ?? 0,
      bestOf: (match['strategy'] as Map<String, dynamic>)['count'] as int,
    );
  }

  Match toEntity() => Match(
        id: id,
        startTime: startTime,
        state: state,
        leagueName: leagueName,
        leagueSlug: leagueSlug,
        leagueImageUrl: leagueImageUrl,
        team1Name: team1Name,
        team1Code: team1Code,
        team1ApiId: team1ApiId,
        team1ImageUrl: team1ImageUrl,
        team1Wins: team1Wins,
        team2Name: team2Name,
        team2Code: team2Code,
        team2ApiId: team2ApiId,
        team2ImageUrl: team2ImageUrl,
        team2Wins: team2Wins,
        bestOf: bestOf,
      );

  static MatchState _parseState(String raw) => switch (raw) {
        'inProgress' => MatchState.inProgress,
        'completed' => MatchState.completed,
        _ => MatchState.unstarted,
      };
}
