import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TeamData {
  const TeamData({
    required this.id,
    required this.mono,
    required this.name,
    required this.region,
    required this.color1,
    required this.color2,
    this.apiId = '',
  });

  final String id;
  final String mono;
  final String name;
  final String region;
  final Color color1;
  final Color color2;
  final String apiId;

  Gradient get gradient => RadialGradient(
        center: const Alignment(-0.36, -0.48),
        radius: 1.0,
        colors: [color1, color2],
      );

  String get nextMatch => _nextMatches[id] ?? 'No upcoming match';

  static const _nextMatches = {
    't1': 'vs Gen.G · Today 20:00',
    'geng': 'vs KT · Jun 18',
    'jdg': 'vs BLG · Live now',
    'blg': 'vs JDG · Live now',
    'g2': 'vs Fnatic · Today 22:00',
    'fnc': 'vs G2 · Today 22:00',
    'c9': 'vs TL · Tomorrow',
    'tl': 'vs C9 · Tomorrow',
    'kt': 'vs HLE · Jun 18',
    'hle': 'vs KT · Jun 18',
  };
}

class PlayerData {
  const PlayerData({
    required this.name,
    required this.role,
    required this.kda,
  });

  final String name;
  final String role;
  final String kda;

  String get initials => name.substring(0, 2).toUpperCase();

  String get roleGlyph => switch (role) {
        'Top' => '▲',
        'Jungle' => '❖',
        'Mid' => '◆',
        'Bot' => '▼',
        'Support' => '✚',
        _ => '?',
      };

  Color get roleColor => switch (role) {
        'Top' => AppColors.primaryLight,
        'Jungle' => AppColors.win,
        'Mid' => AppColors.accent,
        'Bot' => AppColors.liveRedLight,
        'Support' => AppColors.support,
        _ => AppColors.textMuted,
      };

  Color get roleBg => roleColor.withValues(alpha: 0.15);
}

class MatchResultData {
  const MatchResultData({
    required this.opponentId,
    required this.result,
    required this.score,
    required this.when,
  });

  final String opponentId;
  final String result;
  final String score;
  final String when;

  bool get isWin => result == 'W';
  Color get resultColor => isWin ? AppColors.win : AppColors.liveRedLight;
  Color get resultBg => isWin
      ? AppColors.win.withValues(alpha: 0.14)
      : AppColors.liveRed.withValues(alpha: 0.14);
}

class HistoryMatchData {
  const HistoryMatchData({
    required this.team1Id,
    required this.team2Id,
    required this.league,
    required this.bo,
    required this.score1,
    required this.score2,
    required this.dateLabel,
  });

  final String team1Id;
  final String team2Id;
  final String league;
  final String bo;
  final int score1;
  final int score2;
  final String dateLabel;

  bool get team1Won => score1 > score2;
  String get scoreText => '$score1 - $score2';
}

class StatTile {
  const StatTile({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
}

class StatBar {
  const StatBar({
    required this.label,
    required this.value,
    required this.pct,
    required this.color,
  });
  final String label;
  final String value;
  final double pct;
  final Color color;
}

class MatchDisplayData {
  const MatchDisplayData({
    required this.id,
    required this.team1Id,
    required this.team2Id,
    required this.league,
    required this.bo,
    required this.isLive,
    this.isCompleted = false,
    this.team1Wins = 0,
    this.team2Wins = 0,
    this.game,
    this.viewers,
    this.scheduledText,
    this.isHeadLive = false,
    this.isHeadUpcoming = false,
    this.isHeadCompleted = false,
  });

  final String id;
  final String team1Id;
  final String team2Id;
  final String league;
  final String bo;
  final bool isLive;
  final bool isCompleted;
  final int team1Wins;
  final int team2Wins;
  final String? game;
  final String? viewers;
  final String? scheduledText;
  final bool isHeadLive;
  final bool isHeadUpcoming;
  final bool isHeadCompleted;

  String get centerText =>
      (isLive || isCompleted) ? '$team1Wins - $team2Wins' : 'VS';
  Color get centerColor =>
      isLive ? AppColors.primary : AppColors.textMuted;
  String get subText =>
      isLive ? (game ?? '') : 'Best of ${bo.substring(2)}';
  String get statusText => isLive
      ? 'LIVE'
      : isCompleted
          ? 'FINAL'
          : (scheduledText ?? '');
  Color get statusColor => isLive
      ? AppColors.liveRedLight
      : isCompleted
          ? AppColors.textMuted
          : AppColors.textSecondary;
  Color get statusBg => isLive
      ? AppColors.liveRed.withValues(alpha: 0.16)
      : Colors.white.withValues(alpha: 0.05);
  Color get statusBorder => isLive
      ? AppColors.liveRed.withValues(alpha: 0.38)
      : Colors.white.withValues(alpha: 0.08);
  Color get glowColor =>
      isLive ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent;
}

class MockData {
  static const teams = <String, TeamData>{
    't1': TeamData(
        id: 't1',
        mono: 'T1',
        name: 'T1',
        region: 'LCK',
        color1: Color(0xFFE2012D),
        color2: Color(0xFF7A0017)),
    'geng': TeamData(
        id: 'geng',
        mono: 'GG',
        name: 'Gen.G',
        region: 'LCK',
        color1: Color(0xFFC8A85A),
        color2: Color(0xFF7E6427)),
    'jdg': TeamData(
        id: 'jdg',
        mono: 'JDG',
        name: 'JD Gaming',
        region: 'LPL',
        color1: Color(0xFFC8102E),
        color2: Color(0xFF6E0A1C)),
    'blg': TeamData(
        id: 'blg',
        mono: 'BLG',
        name: 'Bilibili Gaming',
        region: 'LPL',
        color1: Color(0xFF22A1E0),
        color2: Color(0xFF125A80)),
    'g2': TeamData(
        id: 'g2',
        mono: 'G2',
        name: 'G2 Esports',
        region: 'LEC',
        color1: Color(0xFFD8D8D8),
        color2: Color(0xFF7C7C7C)),
    'fnc': TeamData(
        id: 'fnc',
        mono: 'FNC',
        name: 'Fnatic',
        region: 'LEC',
        color1: Color(0xFFFF5900),
        color2: Color(0xFF993500)),
    'c9': TeamData(
        id: 'c9',
        mono: 'C9',
        name: 'Cloud9',
        region: 'LCS',
        color1: Color(0xFF1797D6),
        color2: Color(0xFF0D5778)),
    'tl': TeamData(
        id: 'tl',
        mono: 'TL',
        name: 'Team Liquid',
        region: 'LCS',
        color1: Color(0xFF0B5FB0),
        color2: Color(0xFF0A1F3A)),
    'kt': TeamData(
        id: 'kt',
        mono: 'KT',
        name: 'KT Rolster',
        region: 'LCK',
        color1: Color(0xFFE6002D),
        color2: Color(0xFF80001B)),
    'hle': TeamData(
        id: 'hle',
        mono: 'HLE',
        name: 'Hanwha Life',
        region: 'LCK',
        color1: Color(0xFFFF7A00),
        color2: Color(0xFF994900)),
  };

  static TeamData team(String id) => teams[id] ?? teams['t1']!;

  static const liveMatches = <MatchDisplayData>[
    MatchDisplayData(
      id: 't1-geng',
      team1Id: 't1',
      team2Id: 'geng',
      league: 'LCK',
      bo: 'BO5',
      isLive: true,
      team1Wins: 1,
      team2Wins: 1,
      game: 'Game 3',
      viewers: '1.2M watching',
      isHeadLive: true,
    ),
    MatchDisplayData(
      id: 'jdg-blg',
      team1Id: 'jdg',
      team2Id: 'blg',
      league: 'LPL',
      bo: 'BO3',
      isLive: true,
      team1Wins: 0,
      team2Wins: 1,
      game: 'Game 2',
      viewers: '684K watching',
    ),
  ];

  static const upcomingMatches = <MatchDisplayData>[
    MatchDisplayData(
      id: 'g2-fnc',
      team1Id: 'g2',
      team2Id: 'fnc',
      league: 'LEC',
      bo: 'BO3',
      isLive: false,
      scheduledText: 'Today · 20:00',
      isHeadUpcoming: true,
    ),
    MatchDisplayData(
      id: 'c9-tl',
      team1Id: 'c9',
      team2Id: 'tl',
      league: 'LCS',
      bo: 'BO5',
      isLive: false,
      scheduledText: 'Tomorrow · 02:00',
    ),
    MatchDisplayData(
      id: 'kt-hle',
      team1Id: 'kt',
      team2Id: 'hle',
      league: 'LCK',
      bo: 'BO5',
      isLive: false,
      scheduledText: 'Jun 18 · 14:00',
    ),
  ];

  static List<MatchDisplayData> get allMatches =>
      [...liveMatches, ...upcomingMatches];

  static const historyMatches = <HistoryMatchData>[
    HistoryMatchData(
        team1Id: 't1', team2Id: 'geng', league: 'LCK', bo: 'BO5',
        score1: 3, score2: 1, dateLabel: 'YESTERDAY — JUN 16'),
    HistoryMatchData(
        team1Id: 'jdg', team2Id: 'blg', league: 'LPL', bo: 'BO3',
        score1: 1, score2: 2, dateLabel: 'YESTERDAY — JUN 16'),
    HistoryMatchData(
        team1Id: 'g2', team2Id: 'fnc', league: 'LEC', bo: 'BO3',
        score1: 2, score2: 1, dateLabel: 'SAT — JUN 14'),
    HistoryMatchData(
        team1Id: 'c9', team2Id: 'tl', league: 'LCS', bo: 'BO5',
        score1: 3, score2: 0, dateLabel: 'SAT — JUN 14'),
    HistoryMatchData(
        team1Id: 't1', team2Id: 'jdg', league: 'Worlds', bo: 'BO5',
        score1: 3, score2: 2, dateLabel: 'THU — JUN 12'),
    HistoryMatchData(
        team1Id: 'kt', team2Id: 'hle', league: 'LCK', bo: 'BO5',
        score1: 2, score2: 1, dateLabel: 'THU — JUN 12'),
    HistoryMatchData(
        team1Id: 'blg', team2Id: 'fnc', league: 'Worlds', bo: 'BO5',
        score1: 2, score2: 0, dateLabel: 'WED — JUN 10'),
    HistoryMatchData(
        team1Id: 'geng', team2Id: 'c9', league: 'Worlds', bo: 'BO5',
        score1: 3, score2: 1, dateLabel: 'WED — JUN 10'),
  ];

  static const defaultRoster = <PlayerData>[
    PlayerData(name: 'Apex', role: 'Top', kda: '4.1'),
    PlayerData(name: 'Wraith', role: 'Jungle', kda: '5.3'),
    PlayerData(name: 'Oracle', role: 'Mid', kda: '6.8'),
    PlayerData(name: 'Volt', role: 'Bot', kda: '7.2'),
    PlayerData(name: 'Aegis', role: 'Support', kda: '5.9'),
  ];

  static const statTiles = <StatTile>[
    StatTile(label: 'WIN RATE', value: '72%', color: AppColors.primary),
    StatTile(label: 'AVG KDA', value: '4.8', color: AppColors.accent),
    StatTile(label: 'FIRST BLOOD', value: '61%', color: AppColors.win),
    StatTile(label: 'AVG GAME', value: '29:40', color: AppColors.textPrimary),
  ];

  static const statBars = <StatBar>[
    StatBar(
        label: 'Gold @15 diff',
        value: '+1.2k',
        pct: 0.74,
        color: AppColors.primary),
    StatBar(
        label: 'Dragon control',
        value: '68%',
        pct: 0.68,
        color: AppColors.accent),
    StatBar(
        label: 'Baron control',
        value: '74%',
        pct: 0.74,
        color: AppColors.win),
    StatBar(
        label: 'Vision score',
        value: '212',
        pct: 0.82,
        color: AppColors.support),
  ];

  static List<MatchResultData> resultsForTeam(String teamId) => [
        const MatchResultData(
            opponentId: 'geng',
            result: 'W',
            score: '3 - 1',
            when: 'Jun 12 · LCK'),
        const MatchResultData(
            opponentId: 'kt',
            result: 'W',
            score: '2 - 0',
            when: 'Jun 8 · LCK'),
        const MatchResultData(
            opponentId: 'hle',
            result: 'L',
            score: '1 - 2',
            when: 'Jun 4 · LCK'),
        const MatchResultData(
            opponentId: 'jdg',
            result: 'W',
            score: '3 - 2',
            when: 'May 30 · Worlds'),
      ];
}
