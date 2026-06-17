import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';

class PlayerModel {
  const PlayerModel({
    required this.summonerName,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.imageUrl,
  });

  final String summonerName;
  final String firstName;
  final String lastName;
  final String role;
  final String imageUrl;

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        summonerName: json['summonerName'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        role: json['role'] as String? ?? '',
        imageUrl: json['image'] as String? ?? '',
      );
}

class TeamRemoteDatasource {
  TeamRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<PlayerModel>> getRoster(String teamApiId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$kEsportsApiBaseUrl/getTeams',
      queryParameters: {'hl': 'en-US', 'id': teamApiId},
      options: Options(headers: {'x-api-key': kEsportsApiKey}),
    );

    final teams = response.data?['data']?['teams'] as List<dynamic>?;
    if (teams == null || teams.isEmpty) {
      throw const ServerFailure('Team not found');
    }

    final players = (teams.first as Map<String, dynamic>)['players'] as List<dynamic>? ?? [];
    return players.cast<Map<String, dynamic>>().map(PlayerModel.fromJson).toList();
  }
}
