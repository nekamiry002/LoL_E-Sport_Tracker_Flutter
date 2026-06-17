import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'data/datasources/match_remote_datasource.dart';
import 'data/datasources/team_remote_datasource.dart';
import 'data/datasources/league_schedule_datasource.dart';
import 'data/repositories/match_repository_impl.dart';
import 'domain/usecases/get_matches.dart';
import 'presentation/providers/match_provider.dart';
import 'presentation/providers/roster_provider.dart';
import 'presentation/providers/team_schedule_provider.dart';
import 'presentation/providers/history_provider.dart';

/// Wraps [child] with all match-feature providers.
Widget matchProviders({required Widget child}) {
  final dio = Dio();
  final matchDatasource = MatchRemoteDatasourceImpl(dio);
  final repository = MatchRepositoryImpl(matchDatasource);
  final getMatches = GetMatches(repository);
  final teamDatasource = TeamRemoteDatasource(dio);
  final scheduleDatasource = LeagueScheduleDatasource(dio);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MatchProvider(getMatches, scheduleDatasource: scheduleDatasource)),
      ChangeNotifierProvider(create: (_) => RosterProvider(teamDatasource)),
      ChangeNotifierProvider(create: (_) => TeamScheduleProvider(scheduleDatasource)),
      ChangeNotifierProvider(create: (_) => HistoryProvider(scheduleDatasource)),
    ],
    child: child,
  );
}
