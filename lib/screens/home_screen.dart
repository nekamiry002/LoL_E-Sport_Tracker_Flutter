import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../features/matches/presentation/providers/match_provider.dart';
import '../widgets/team_logo.dart';
import '../widgets/live_pulse_dot.dart';

enum CardStyle { classic, compact, featured }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CardStyle _cardStyle = CardStyle.classic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchMatches();
    });
  }

  void _openTeam(String teamCode) {
    Navigator.pushNamed(context, '/team', arguments: teamCode);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

    return Column(
      children: [
        _Header(
          cardStyle: _cardStyle,
          onCardStyleChanged: (s) => setState(() => _cardStyle = s),
        ),
        _FilterChips(
          selected: provider.leagueFilter,
          leagues: provider.availableLeagues,
          onSelected: provider.setFilter,
        ),
        Expanded(
          child: switch (provider.status) {
            MatchesStatus.initial || MatchesStatus.loading =>
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            MatchesStatus.failure => _ErrorView(
                message: provider.error ?? 'Unknown error',
                onRetry: () => provider.fetchMatches(),
              ),
            MatchesStatus.success => _MatchList(
                matches: provider.displayMatches,
                cardStyle: _cardStyle,
                onTeamTap: _openTeam,
                provider: provider,
              ),
          },
        ),
      ],
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({
    required this.matches,
    required this.cardStyle,
    required this.onTeamTap,
    required this.provider,
  });

  final List<MatchDisplayData> matches;
  final CardStyle cardStyle;
  final ValueChanged<String> onTeamTap;
  final MatchProvider provider;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No matches found',
          style: AppTheme.rajdhani(
            fontSize: 16,
            color: AppColors.textSubtle,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: const Color(0xFF1A1A2E),
      onRefresh: () => provider.fetchMatches(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 26),
        itemCount: matches.length,
        itemBuilder: (context, i) {
          final m = matches[i];
          final t1 = provider.teamFor(m.team1Id);
          final t2 = provider.teamFor(m.team2Id);
          return _MatchSection(
            match: m,
            t1: t1,
            t2: t2,
            cardStyle: cardStyle,
            onTapTeam1: () => onTeamTap(m.team1Id),
            onTapTeam2: () => onTeamTap(m.team2Id),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textSubtle, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load matches',
              style: AppTheme.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.barlow(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'RETRY',
                  style: AppTheme.rajdhani(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 2,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.cardStyle, required this.onCardStyleChanged});

  final CardStyle cardStyle;
  final ValueChanged<CardStyle> onCardStyleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: Row(
        children: [
          _IconBtn(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Bar(color: AppColors.primary),
                const SizedBox(height: 4),
                _Bar(color: AppColors.textPrimary),
                const SizedBox(height: 4),
                _Bar(color: AppColors.textPrimary, width: 12),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'MATCHES',
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LOL ESPORT TRACKER',
                  style: AppTheme.rajdhani(
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          _IconBtn(
            onTap: () => _showStylePicker(context),
            child: const Icon(
              Icons.tune,
              color: AppColors.textSubtle,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showStylePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CARD STYLE',
              style: AppTheme.rajdhani(
                fontSize: 13,
                letterSpacing: 2,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...CardStyle.values.map(
              (s) => ListTile(
                title: Text(
                  s.name.toUpperCase(),
                  style: AppTheme.rajdhani(fontSize: 16),
                ),
                trailing: cardStyle == s
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onCardStyleChanged(s);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color, this.width = 18});
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.leagues,
    required this.onSelected,
  });

  final String selected;
  final List<String> leagues;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = ['ALL', ...leagues];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        children: filters.map((f) {
          final isActive = f == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 1,
                    color: isActive
                        ? AppColors.primaryLight
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Match section (section header + card) ───────────────────────────────────

class _MatchSection extends StatelessWidget {
  const _MatchSection({
    required this.match,
    required this.t1,
    required this.t2,
    required this.cardStyle,
    required this.onTapTeam1,
    required this.onTapTeam2,
  });

  final MatchDisplayData match;
  final TeamData t1;
  final TeamData t2;
  final CardStyle cardStyle;
  final VoidCallback onTapTeam1;
  final VoidCallback onTapTeam2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (match.isHeadLive) const _SectionHeader(label: 'LIVE NOW', isLive: true),
        if (match.isHeadUpcoming) const _SectionHeader(label: 'UPCOMING', isLive: false),
        if (match.isHeadCompleted) const _SectionHeader(label: 'COMPLETED', isLive: false),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: switch (cardStyle) {
            CardStyle.classic => ClassicMatchCard(match: match, t1: t1, t2: t2, onTapTeam1: onTapTeam1, onTapTeam2: onTapTeam2),
            CardStyle.compact => CompactMatchCard(match: match, t1: t1, t2: t2, onTapTeam1: onTapTeam1, onTapTeam2: onTapTeam2),
            CardStyle.featured => FeaturedMatchCard(match: match, t1: t1, t2: t2, onTapTeam1: onTapTeam1, onTapTeam2: onTapTeam2),
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isLive});
  final String label;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isLive ? 4 : 22, bottom: 13, left: 2, right: 2),
      child: Row(
        children: [
          if (isLive) ...[
            const LivePulseDot(size: 7),
            const SizedBox(width: 9),
          ],
          Text(
            label,
            style: AppTheme.rajdhani(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 2.5,
              color: isLive ? AppColors.liveRedLight : AppColors.primary,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isLive ? AppColors.liveRed : AppColors.primary)
                        .withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Classic card ─────────────────────────────────────────────────────────────

class ClassicMatchCard extends StatelessWidget {
  const ClassicMatchCard({
    super.key,
    required this.match,
    required this.t1,
    required this.t2,
    required this.onTapTeam1,
    required this.onTapTeam2,
  });

  final MatchDisplayData match;
  final TeamData t1;
  final TeamData t2;
  final VoidCallback onTapTeam1;
  final VoidCallback onTapTeam2;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            if (match.isLive)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        AppColors.liveRed.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        LeagueBadge(league: match.league),
                        const SizedBox(width: 9),
                        Text(
                          match.bo,
                          style: AppTheme.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ]),
                      StatusPill(match: match),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onTapTeam1,
                          child: Column(children: [
                            TeamLogo(team: t1, size: 54),
                            const SizedBox(height: 9),
                            Text(
                              t1.name,
                              textAlign: TextAlign.center,
                              style: AppTheme.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        width: 78,
                        child: Column(children: [
                          Text(
                            match.centerText,
                            style: AppTheme.rajdhani(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: match.centerColor,
                            ),
                          ),
                          Text(
                            match.subText,
                            style: AppTheme.barlow(
                              fontSize: 10,
                              letterSpacing: 1,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ]),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: onTapTeam2,
                          child: Column(children: [
                            TeamLogo(team: t2, size: 54),
                            const SizedBox(height: 9),
                            Text(
                              t2.name,
                              textAlign: TextAlign.center,
                              style: AppTheme.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

// ─── Compact card ─────────────────────────────────────────────────────────────

class CompactMatchCard extends StatelessWidget {
  const CompactMatchCard({
    super.key,
    required this.match,
    required this.t1,
    required this.t2,
    required this.onTapTeam1,
    required this.onTapTeam2,
  });

  final MatchDisplayData match;
  final TeamData t1;
  final TeamData t2;
  final VoidCallback onTapTeam1;
  final VoidCallback onTapTeam2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(
              color: AppColors.leagueColor(match.league), width: 3),
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapTeam1,
              child: Row(children: [
                TeamLogo(team: t1, size: 34),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    t1.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Column(children: [
            Text(
              match.centerText,
              style: AppTheme.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: match.centerColor,
              ),
            ),
            Text(
              match.statusText,
              style: AppTheme.barlow(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: match.statusColor,
              ),
            ),
          ]),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTapTeam2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      t2.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTheme.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  TeamLogo(team: t2, size: 34),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Featured card ────────────────────────────────────────────────────────────

class FeaturedMatchCard extends StatelessWidget {
  const FeaturedMatchCard({
    super.key,
    required this.match,
    required this.t1,
    required this.t2,
    required this.onTapTeam1,
    required this.onTapTeam2,
  });

  final MatchDisplayData match;
  final TeamData t1;
  final TeamData t2;
  final VoidCallback onTapTeam1;
  final VoidCallback onTapTeam2;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.6, -1),
            end: Alignment(1, 1),
            colors: [Color(0xD9141C30), Color(0xFF0C1322)],
          ),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 34,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: -34,
              left: -22,
              width: 130,
              height: 130,
              child: _GlowOrb(gradient: t1.gradient),
            ),
            Positioned(
              top: -34,
              right: -22,
              width: 130,
              height: 130,
              child: _GlowOrb(gradient: t2.gradient),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        LeagueBadge(league: match.league, dark: true),
                        const SizedBox(width: 9),
                        Text(
                          match.bo,
                          style: AppTheme.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]),
                      StatusPill(match: match),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onTapTeam1,
                          child: Column(children: [
                            TeamLogo(team: t1, size: 60),
                            const SizedBox(height: 10),
                            Text(
                              t1.name,
                              style: AppTheme.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        width: 84,
                        child: Column(children: [
                          Text(
                            match.centerText,
                            style: AppTheme.rajdhani(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: match.centerColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            match.subText,
                            style: AppTheme.barlow(
                              fontSize: 10,
                              letterSpacing: 1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ]),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: onTapTeam2,
                          child: Column(children: [
                            TeamLogo(team: t2, size: 60),
                            const SizedBox(height: 10),
                            Text(
                              t2.name,
                              style: AppTheme.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (match.isLive) ...[
                        Row(children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.liveRedLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            match.viewers ?? '',
                            style: AppTheme.barlow(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ]),
                        _WatchButton(),
                      ] else ...[
                        Text(
                          match.scheduledText ?? '',
                          style: AppTheme.barlow(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const _ReminderButton(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.gradient});
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
      child: Opacity(
        opacity: 0.28,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _WatchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2454A), Color(0xFFA81E22)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.liveRed.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        'WATCH LIVE',
        style: AppTheme.rajdhani(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ReminderButton extends StatelessWidget {
  const _ReminderButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'SET REMINDER',
        style: AppTheme.rajdhani(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 1.5,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class LeagueBadge extends StatelessWidget {
  const LeagueBadge({super.key, required this.league, this.dark = false});
  final String league;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        league,
        style: AppTheme.rajdhani(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.5,
          color: AppColors.leagueColor(league),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.match});
  final MatchDisplayData match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      decoration: BoxDecoration(
        color: match.statusBg,
        border: Border.all(color: match.statusBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (match.isLive) ...[
            const LivePulseDot(size: 6),
            const SizedBox(width: 6),
          ],
          Text(
            match.statusText,
            style: AppTheme.rajdhani(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.5,
              color: match.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

