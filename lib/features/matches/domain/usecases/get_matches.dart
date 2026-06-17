import '../entities/match.dart';
import '../repositories/match_repository.dart';

class GetMatches {
  const GetMatches(this._repository);

  final MatchRepository _repository;

  Future<List<Match>> call({List<String>? leagueIds}) =>
      _repository.getMatches(leagueIds: leagueIds);
}
