import '../entities/match.dart';

abstract class MatchRepository {
  Future<List<Match>> getMatches({List<String>? leagueIds});
}
