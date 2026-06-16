enum MatchState { unstarted, inProgress, completed }

class Match {
  const Match({
    required this.id,
    required this.startTime,
    required this.state,
    required this.leagueName,
    required this.leagueSlug,
    required this.leagueImageUrl,
    required this.team1Name,
    required this.team1Code,
    required this.team1ImageUrl,
    required this.team1Wins,
    required this.team2Name,
    required this.team2Code,
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
  final String team1ImageUrl;
  final int team1Wins;
  final String team2Name;
  final String team2Code;
  final String team2ImageUrl;
  final int team2Wins;
  final int bestOf;
}
