import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../widgets/hex_clipper.dart';
import '../widgets/hex_logo.dart';
import '../widgets/live_pulse_dot.dart';

enum CardStyle { classic, compact, featured }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CardStyle _cardStyle = CardStyle.classic;
  String _filter = 'ALL';

  List<MatchDisplayData> get _filteredMatches {
    if (_filter == 'ALL') return MockData.allMatches;
    return MockData.allMatches.where((m) => m.league == _filter).toList();
  }

  void _openTeam(String teamId) {
    Navigator.pushNamed(context, '/team', arguments: teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          cardStyle: _cardStyle,
          onCardStyleChanged: (s) => setState(() => _cardStyle = s),
        ),
        _FilterChips(
          selected: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 26),
            itemCount: _filteredMatches.length,
            itemBuilder: (context, i) {
              final m = _filteredMatches[i];
              return _MatchSection(
                match: m,
                cardStyle: _cardStyle,
                onTap: () => _openTeam(m.team1Id),
              );
            },
          ),
        ),
      ],
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
  const _FilterChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  static const _filters = ['ALL', 'LCK', 'LPL', 'LEC', 'LCS'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        children: _filters.map((f) {
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
    required this.cardStyle,
    required this.onTap,
  });

  final MatchDisplayData match;
  final CardStyle cardStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (match.isHeadLive) const _SectionHeader(isLive: true),
        if (match.isHeadUpcoming) const _SectionHeader(isLive: false),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: switch (cardStyle) {
            CardStyle.classic => ClassicMatchCard(match: match, onTap: onTap),
            CardStyle.compact => CompactMatchCard(match: match, onTap: onTap),
            CardStyle.featured => FeaturedMatchCard(match: match, onTap: onTap),
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.isLive});
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
            isLive ? 'LIVE NOW' : 'UPCOMING',
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
  const ClassicMatchCard({super.key, required this.match, required this.onTap});

  final MatchDisplayData match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t1 = MockData.team(match.team1Id);
    final t2 = MockData.team(match.team2Id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                        child: Column(children: [
                          HexLogo(size: 54, gradient: t1.gradient, mono: t1.mono),
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
                        child: Column(children: [
                          HexLogo(size: 54, gradient: t2.gradient, mono: t2.mono),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Compact card ─────────────────────────────────────────────────────────────

class CompactMatchCard extends StatelessWidget {
  const CompactMatchCard({super.key, required this.match, required this.onTap});

  final MatchDisplayData match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t1 = MockData.team(match.team1Id);
    final t2 = MockData.team(match.team2Id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: Row(children: [
                SmallHexLogo(gradient: t1.gradient, mono: t1.mono),
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
                  SmallHexLogo(gradient: t2.gradient, mono: t2.mono),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Featured card ────────────────────────────────────────────────────────────

class FeaturedMatchCard extends StatelessWidget {
  const FeaturedMatchCard(
      {super.key, required this.match, required this.onTap});

  final MatchDisplayData match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t1 = MockData.team(match.team1Id);
    final t2 = MockData.team(match.team2Id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                        child: Column(children: [
                          HexLogo(size: 60, gradient: t1.gradient, mono: t1.mono),
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
                        child: Column(children: [
                          HexLogo(size: 60, gradient: t2.gradient, mono: t2.mono),
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

class SmallHexLogo extends StatelessWidget {
  const SmallHexLogo({super.key, required this.gradient, required this.mono});
  final Gradient gradient;
  final String mono;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexClipper(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(gradient: gradient),
        alignment: Alignment.center,
        child: Text(
          mono,
          style: AppTheme.rajdhani(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
