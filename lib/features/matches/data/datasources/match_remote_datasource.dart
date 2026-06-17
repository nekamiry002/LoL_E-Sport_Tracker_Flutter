import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../models/match_model.dart';

abstract class MatchRemoteDatasource {
  Future<List<MatchModel>> getMatches({List<String>? leagueIds});
  /// Fetches past matches and returns a team-code → numeric-apiId map.
  /// Used to fill in apiIds for teams that have no upcoming matches.
  Future<Map<String, String>> getTeamIds({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? leagueIds,
  });
}

class MatchRemoteDatasourceImpl implements MatchRemoteDatasource {
  MatchRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<MatchModel>> getMatches({List<String>? leagueIds}) async {
    final now = DateTime.now().toUtc();
    final end = now.add(const Duration(days: 90));

    final variables = jsonEncode({
      'hl': 'en-US',
      'sport': 'lol',
      'eventDateStart': now.toIso8601String(),
      'eventDateEnd': end.toIso8601String(),
      'leagues': leagueIds ?? kLeagueIds.values.toList(),
      'eventState': ['inProgress', 'completed', 'unstarted'],
      'pageSize': 300,
      'eventType': 'match',
    });

    final extensions = jsonEncode({
      'persistedQuery': {
        'version': 1,
        'sha256Hash': kGqlHash,
      },
    });

    final response = await _dio.get<Map<String, dynamic>>(
      kLolesportsBaseUrl,
      queryParameters: {
        'operationName': 'homeEvents',
        'variables': variables,
        'extensions': extensions,
      },
      options: Options(
        headers: kIsWeb ? kLolesportsHeadersWeb : kLolesportsHeaders,
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    final body = response.data;
    if (response.statusCode != 200 || body == null) {
      throw const ServerFailure('Invalid response from lolesports API');
    }

    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw const ServerFailure('Missing "data" in API response');

    final esports = data['esports'] as Map<String, dynamic>?;
    if (esports == null) throw const ServerFailure('Missing "esports" in API response');

    final events = (esports['events'] as List<dynamic>?) ?? <dynamic>[];

    return events
        .cast<Map<String, dynamic>>()
        .map(MatchModel.fromJson)
        .toList();
  }

  @override
  Future<Map<String, String>> getTeamIds({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? leagueIds,
  }) async {
    final variables = jsonEncode({
      'hl': 'en-US',
      'sport': 'lol',
      'eventDateStart': startDate.toIso8601String(),
      'eventDateEnd': endDate.toIso8601String(),
      'leagues': leagueIds ?? kLeagueIds.values.toList(),
      'eventState': ['completed'],
      'pageSize': 500,
      'eventType': 'match',
    });

    final extensions = jsonEncode({
      'persistedQuery': {
        'version': 1,
        'sha256Hash': kGqlHash,
      },
    });

    final response = await _dio.get<Map<String, dynamic>>(
      kLolesportsBaseUrl,
      queryParameters: {
        'operationName': 'homeEvents',
        'variables': variables,
        'extensions': extensions,
      },
      options: Options(
        headers: kIsWeb ? kLolesportsHeadersWeb : kLolesportsHeaders,
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    final esports = response.data?['data']?['esports'] as Map<String, dynamic>?;
    final events = (esports?['events'] as List<dynamic>?) ?? [];

    String extractId(String raw) =>
        raw.contains(':') ? raw.split(':').last : raw;

    final result = <String, String>{};
    for (final raw in events) {
      final teams = (raw as Map<String, dynamic>)['matchTeams'] as List<dynamic>? ?? [];
      for (final t in teams) {
        final team = t as Map<String, dynamic>;
        final code = team['code'] as String? ?? '';
        final rawId = team['id'] as String? ?? '';
        if (code.isNotEmpty && rawId.isNotEmpty) {
          result[code] = extractId(rawId);
        }
      }
    }
    return result;
  }
}
