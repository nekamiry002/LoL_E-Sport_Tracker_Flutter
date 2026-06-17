import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import 'notification_service.dart';

/// Handles scheduling start notifications + detecting completed results.
class NotificationScheduler {
  NotificationScheduler._();
  static final instance = NotificationScheduler._();

  static const _keySeenResults = 'notif_seen_result_ids';

  final _svc = NotificationService.instance;

  /// Fetches all events across all leagues and runs scheduleUpcoming + checkResults.
  Future<void> refresh({
    required Set<String> favCodes,
    required bool notifStart,
    required bool notifEnd,
  }) async {
    if (favCodes.isEmpty) return;
    if (!notifStart && !notifEnd) return;

    final dio = Dio();
    final upcoming = <ScheduleEventSummary>[];
    final completed = <ScheduleEventSummary>[];

    for (final entry in kLeagueIds.entries) {
      try {
        final events = await _fetchEvents(dio, entry.value, entry.key);
        upcoming.addAll(events.where((e) => e.state == 'unstarted'));
        completed.addAll(events.where((e) => e.state == 'completed'));
      } catch (_) {}
    }

    if (notifStart) {
      await _scheduleUpcoming(upcoming: upcoming, favCodes: favCodes);
    }
    if (notifEnd) {
      await _checkResults(completed: completed, favCodes: favCodes);
    }
  }

  Future<void> _scheduleUpcoming({
    required List<ScheduleEventSummary> upcoming,
    required Set<String> favCodes,
  }) async {
    // Cancel existing start notifs before rescheduling
    final pending = await _svc.pending();
    for (final p in pending) {
      if ((p.body ?? '').contains('starts in 5 minutes')) {
        await _svc.cancel(p.id);
      }
    }

    for (final event in upcoming) {
      final isFav = favCodes.contains(event.team1Code) ||
          favCodes.contains(event.team2Code);
      if (!isFav) continue;

      final favTeam = favCodes.contains(event.team1Code)
          ? event.team1Code
          : event.team2Code;
      final opp =
          favTeam == event.team1Code ? event.team2Code : event.team1Code;

      await _svc.scheduleMatchStart(
        notifId: event.matchId.hashCode.abs() % 100000,
        title: '⚔️ $favTeam vs $opp · ${event.leagueName}',
        body: 'Match starts in 5 minutes!',
        startTime: event.startTime,
      );
    }
  }

  Future<void> _checkResults({
    required List<ScheduleEventSummary> completed,
    required Set<String> favCodes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final seen =
        Set<String>.from(prefs.getStringList(_keySeenResults) ?? []);

    for (final event in completed) {
      if (seen.contains(event.matchId)) continue;

      final isFav = favCodes.contains(event.team1Code) ||
          favCodes.contains(event.team2Code);
      if (!isFav) continue;

      final favTeam = favCodes.contains(event.team1Code)
          ? event.team1Code
          : event.team2Code;
      final favWins = favTeam == event.team1Code ? event.team1Wins : event.team2Wins;
      final oppWins = favTeam == event.team1Code ? event.team2Wins : event.team1Wins;
      final opp =
          favTeam == event.team1Code ? event.team2Code : event.team1Code;
      final won = favWins > oppWins;

      await _svc.showNow(
        notifId: 'res_${event.matchId}'.hashCode.abs() % 100000,
        title: won
            ? '🏆 $favTeam won! $favWins-$oppWins vs $opp'
            : '😔 $favTeam lost $favWins-$oppWins vs $opp',
        body: event.leagueName,
      );

      seen.add(event.matchId);
    }

    await prefs.setStringList(_keySeenResults, seen.toList());
  }

  Future<List<ScheduleEventSummary>> _fetchEvents(
      Dio dio, String leagueId, String leagueSlug) async {
    final response = await dio.get<Map<String, dynamic>>(
      '$kEsportsApiBaseUrl/getSchedule',
      queryParameters: {'hl': 'en-US', 'leagueId': leagueId},
      options: Options(headers: {'x-api-key': kEsportsApiKey}),
    );

    final events =
        (response.data?['data']?['schedule']?['events'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];

    final String leagueName;
    if (events.isNotEmpty) {
      final raw = (events.first['league'] as Map?)?['name'] as String?;
      leagueName = raw ?? leagueSlug;
    } else {
      leagueName = leagueSlug;
    }

    return events.map((e) {
      final teams = (e['match']?['teams'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      final t1 = teams.isNotEmpty ? teams[0] : <String, dynamic>{};
      final t2 = teams.length > 1 ? teams[1] : <String, dynamic>{};
      final r1 = t1['result'] as Map<String, dynamic>? ?? {};
      final r2 = t2['result'] as Map<String, dynamic>? ?? {};
      return ScheduleEventSummary(
        matchId: e['match']?['id'] as String? ?? '',
        state: e['state'] as String? ?? '',
        startTime:
            DateTime.tryParse(e['startTime'] as String? ?? '') ?? DateTime.now(),
        leagueName: leagueName,
        team1Code: t1['code'] as String? ?? '',
        team1Wins: (r1['gameWins'] as int?) ?? 0,
        team2Code: t2['code'] as String? ?? '',
        team2Wins: (r2['gameWins'] as int?) ?? 0,
      );
    }).where((e) => e.matchId.isNotEmpty).toList();
  }
}

class ScheduleEventSummary {
  const ScheduleEventSummary({
    required this.matchId,
    required this.state,
    required this.startTime,
    required this.leagueName,
    required this.team1Code,
    required this.team1Wins,
    required this.team2Code,
    required this.team2Wins,
  });
  final String matchId;
  final String state;
  final DateTime startTime;
  final String leagueName;
  final String team1Code;
  final int team1Wins;
  final String team2Code;
  final int team2Wins;
}
