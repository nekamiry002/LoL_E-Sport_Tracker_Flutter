import 'package:flutter/material.dart';

import '../../domain/entities/match.dart';
import '../../../../data/mock_data.dart';

// Known team colors — fallback to generated color if not listed.
const _knownColors = <String, (Color, Color)>{
  'T1':  (Color(0xFFE2012D), Color(0xFF7A0017)),
  'GEN': (Color(0xFFC8A85A), Color(0xFF7E6427)),
  'JDG': (Color(0xFFC8102E), Color(0xFF6E0A1C)),
  'BLG': (Color(0xFF22A1E0), Color(0xFF125A80)),
  'G2':  (Color(0xFFD8D8D8), Color(0xFF7C7C7C)),
  'FNC': (Color(0xFFFF5900), Color(0xFF993500)),
  'C9':  (Color(0xFF1797D6), Color(0xFF0D5778)),
  'TL':  (Color(0xFF0B5FB0), Color(0xFF0A1F3A)),
  'KT':  (Color(0xFFE6002D), Color(0xFF80001B)),
  'HLE': (Color(0xFFFF7A00), Color(0xFF994900)),
  'NRG': (Color(0xFFFF6B00), Color(0xFF8A3A00)),
  'FLY': (Color(0xFF1FC7C7), Color(0xFF0D6A6A)),
  'MAD': (Color(0xFF00C8FF), Color(0xFF006E8A)),
  'VIT': (Color(0xFF9B2335), Color(0xFF5A1020)),
  'RGE': (Color(0xFF3568B5), Color(0xFF1C3A63)),
  'BDS': (Color(0xFF00A859), Color(0xFF005C30)),
  'SK':  (Color(0xFFFF8C00), Color(0xFF8B4C00)),
  'XL':  (Color(0xFF6B2FA0), Color(0xFF3A1A58)),
};

Color _colorFromCode(String code) {
  final hash = code.codeUnits.fold(0, (a, b) => a * 31 + b);
  const palette = [
    Color(0xFF4B8CE8), Color(0xFFE84B4B), Color(0xFF4BE87A),
    Color(0xFFE8C44B), Color(0xFF9B4BE8), Color(0xFF4BE8E8),
    Color(0xFFE8844B), Color(0xFF4BE89B),
  ];
  return palette[hash.abs() % palette.length];
}

TeamData teamDataFromApi({
  required String code,
  required String name,
  required String leagueSlug,
  required String apiId,
  String imageUrl = '',
}) {
  final colors = _knownColors[code];
  final c1 = colors?.$1 ?? _colorFromCode(code);
  final c2 = colors?.$2 ?? _colorFromCode(code + code).withValues(alpha: 0.6);
  return TeamData(
    id: code,
    mono: code.length > 3 ? code.substring(0, 3) : code,
    name: name,
    region: leagueSlug.toUpperCase(),
    color1: c1,
    color2: c2,
    apiId: apiId,
    imageUrl: imageUrl,
  );
}

bool _isAcademyTeam(String name) {
  final n = name.toLowerCase();
  return n.contains('academy') ||
      n.contains(' blue') ||
      n.contains('challengers') ||
      n.contains('next gen') ||
      n.contains('reserves') ||
      n.contains('youth') ||
      n.endsWith(' b');
}

/// Converts a sorted list of [Match] from the API into [MatchDisplayData]
/// and populates [teamRegistry] with [TeamData] for each team encountered.
List<MatchDisplayData> adaptMatches(
  List<Match> matches,
  Map<String, TeamData> teamRegistry,
) {
  // Sort: live first, then upcoming, then completed
  final sorted = [...matches]..sort((a, b) {
      int order(MatchState s) => switch (s) {
            MatchState.inProgress => 0,
            MatchState.unstarted => 1,
            MatchState.completed => 2,
          };
      return order(a.state).compareTo(order(b.state));
    });

  bool liveHeaderDone = false;
  bool upcomingHeaderDone = false;
  bool completedHeaderDone = false;

  return sorted.map((m) {
    // Register teams (skip TBD placeholders and academy/secondary teams)
    if (m.team1Code.isNotEmpty && m.team1Code != 'TBD' && _isAcademyTeam(m.team1Name)) {
      debugPrint('[DEBUG] adaptMatches FILTERED academy: "${m.team1Name}" (${m.team1Code})');
    }
    if (m.team2Code.isNotEmpty && m.team2Code != 'TBD' && _isAcademyTeam(m.team2Name)) {
      debugPrint('[DEBUG] adaptMatches FILTERED academy: "${m.team2Name}" (${m.team2Code})');
    }
    if (m.team1Code.isNotEmpty && m.team1Code != 'TBD' && !_isAcademyTeam(m.team1Name)) {
      teamRegistry.putIfAbsent(
        m.team1Code,
        () => teamDataFromApi(
          code: m.team1Code,
          name: m.team1Name,
          leagueSlug: m.leagueSlug,
          apiId: m.team1ApiId,
          imageUrl: m.team1ImageUrl,
        ),
      );
    }
    if (m.team2Code.isNotEmpty && m.team2Code != 'TBD' && !_isAcademyTeam(m.team2Name)) {
      teamRegistry.putIfAbsent(
        m.team2Code,
        () => teamDataFromApi(
          code: m.team2Code,
          name: m.team2Name,
          leagueSlug: m.leagueSlug,
          apiId: m.team2ApiId,
          imageUrl: m.team2ImageUrl,
        ),
      );
    }

    final isLive = m.state == MatchState.inProgress;
    final isUpcoming = m.state == MatchState.unstarted;
    final isCompleted = m.state == MatchState.completed;

    final needsLiveHead = isLive && !liveHeaderDone;
    final needsUpcomingHead = isUpcoming && !upcomingHeaderDone;
    final needsCompletedHead = isCompleted && !completedHeaderDone;

    if (needsLiveHead) liveHeaderDone = true;
    if (needsUpcomingHead) upcomingHeaderDone = true;
    if (needsCompletedHead) completedHeaderDone = true;

    final game = isLive
        ? 'Game ${m.team1Wins + m.team2Wins + 1}'
        : null;

    return MatchDisplayData(
      id: m.id,
      team1Id: m.team1Code,
      team2Id: m.team2Code,
      league: m.leagueName,
      bo: 'BO${m.bestOf}',
      isLive: isLive,
      isCompleted: isCompleted,
      team1Wins: m.team1Wins,
      team2Wins: m.team2Wins,
      game: game,
      scheduledText: isUpcoming ? _formatDate(m.startTime) : null,
      isHeadLive: needsLiveHead,
      isHeadUpcoming: needsUpcomingHead,
      isHeadCompleted: needsCompletedHead,
    );
  }).toList();
}

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final matchDay = DateTime(local.year, local.month, local.day);
  final diff = matchDay.difference(today).inDays;

  final hour = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  final time = '$hour:$min';

  if (diff == 0) return 'Today · $time';
  if (diff == 1) return 'Tomorrow · $time';

  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[local.month]} ${local.day} · $time';
}
