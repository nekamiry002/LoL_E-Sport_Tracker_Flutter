import '../../domain/entities/match.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_datasource.dart';

class MatchRepositoryImpl implements MatchRepository {
  const MatchRepositoryImpl(this._datasource);

  final MatchRemoteDatasource _datasource;

  @override
  Future<List<Match>> getMatches({List<String>? leagueIds}) async {
    final models = await _datasource.getMatches(leagueIds: leagueIds);
    return models.map((m) => m.toEntity()).toList();
  }
}
