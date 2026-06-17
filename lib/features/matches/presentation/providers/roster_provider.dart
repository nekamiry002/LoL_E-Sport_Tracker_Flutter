import 'package:flutter/foundation.dart';

import '../../data/datasources/team_remote_datasource.dart';

enum RosterStatus { initial, loading, success, failure }

class RosterProvider extends ChangeNotifier {
  RosterProvider(this._datasource);

  final TeamRemoteDatasource _datasource;

  final Map<String, List<PlayerModel>> _cache = {};
  final Map<String, RosterStatus> _statusMap = {};
  final Map<String, String?> _errorMap = {};

  List<PlayerModel> playersFor(String teamApiId) => _cache[teamApiId] ?? [];
  RosterStatus statusFor(String teamApiId) => _statusMap[teamApiId] ?? RosterStatus.initial;
  String? errorFor(String teamApiId) => _errorMap[teamApiId];

  Future<void> fetchRoster(String teamApiId) async {
    if (teamApiId.isEmpty) return;
    if (_statusMap[teamApiId] == RosterStatus.success) return;

    _statusMap[teamApiId] = RosterStatus.loading;
    _errorMap[teamApiId] = null;
    notifyListeners();

    try {
      _cache[teamApiId] = await _datasource.getRoster(teamApiId);
      _statusMap[teamApiId] = RosterStatus.success;
    } catch (e) {
      _errorMap[teamApiId] = e.toString();
      _statusMap[teamApiId] = RosterStatus.failure;
    }

    notifyListeners();
  }
}
