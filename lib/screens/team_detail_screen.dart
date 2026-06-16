import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/app_provider.dart';
import '../widgets/hex_logo.dart';
import '../widgets/hex_pattern.dart';

class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final team = MockData.team(teamId);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _TeamDetailBody(team: team, teamId: teamId),
    );
  }
}

class _TeamDetailBody extends StatefulWidget {
  const _TeamDetailBody({required this.team, required this.teamId});

  final TeamData team;
  final String teamId;

  @override
  State<_TeamDetailBody> createState() => _TeamDetailBodyState();
}

class _TeamDetailBodyState extends State<_TeamDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFaved =
        context.watch<AppProvider>().isFavorite(widget.teamId);
    final team = widget.team;

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverToBoxAdapter(child: _Banner(team: team, isFaved: isFaved, teamId: widget.teamId)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(_tabs),
        ),
      ],
      body: TabBarView(
        controller: _tabs,
        children: [
          _RosterTab(teamId: widget.teamId),
          const _StatsTab(),
          _ResultsTab(teamId: widget.teamId),
          _NextMatchTab(teamId: widget.teamId),
        ],
      ),
    );
  }
}

// ─── Banner ───────────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  const _Banner({
    required this.team,
    required this.isFaved,
    required this.teamId,
  });

  final TeamData team;
  final bool isFaved;
  final String teamId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0, -1),
                  end: const Alignment(0, 0.5),
                  colors: [team.color1, AppColors.background],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1),
                    radius: 1.0,
                    colors: [team.color1, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: HexPattern(color: Colors.white),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.1),
                    AppColors.background.withValues(alpha: 0.85),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 16,
                  child: _BackButton(),
                ),
                Positioned(
                  top: 8,
                  right: 16,
                  child: _FavButton(teamId: teamId, isFaved: isFaved),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Column(
                    children: [
                      HexLogo(
                        size: 76,
                        gradient: team.gradient,
                        mono: team.mono,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        team.name,
                        style: AppTheme.rajdhani(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${team.region} · ${_regionFull(team.region)}',
                        style: AppTheme.barlow(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _regionFull(String r) => switch (r) {
        'LCK' => 'Korea',
        'LPL' => 'China',
        'LEC' => 'EMEA',
        'LCS' => 'North America',
        _ => r,
      };
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x8005070D),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.chevron_left,
            color: AppColors.textPrimary, size: 24),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.teamId, required this.isFaved});
  final String teamId;
  final bool isFaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppProvider>().toggleFavorite(teamId),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x8005070D),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isFaved ? Icons.star : Icons.star_outline,
          color: isFaved ? AppColors.primary : AppColors.textSubtle,
          size: 22,
        ),
      ),
    );
  }
}

// ─── Sticky tab bar ───────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.controller);
  final TabController controller;

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.96),
      child: TabBar(
        controller: controller,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
        labelStyle: AppTheme.rajdhani(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppTheme.rajdhani(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppColors.textDim,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textDim,
        dividerColor: Colors.white.withValues(alpha: 0.07),
        tabs: const [
          Tab(text: 'ROSTER'),
          Tab(text: 'STATS'),
          Tab(text: 'RESULTS'),
          Tab(text: 'NEXT'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ─── Roster tab ───────────────────────────────────────────────────────────────

class _RosterTab extends StatelessWidget {
  const _RosterTab({required this.teamId});
  final String teamId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.defaultRoster.length,
      itemBuilder: (_, i) => _PlayerCard(player: MockData.defaultRoster[i]),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player});
  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B2540), Color(0xFF0D1626)],
              ),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              player.initials,
              style: AppTheme.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 7),
                Row(children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: player.roleBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      player.roleGlyph,
                      style: TextStyle(
                          fontSize: 11,
                          color: player.roleColor,
                          height: 1),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    player.role.toUpperCase(),
                    style: AppTheme.barlow(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                player.kda,
                style: AppTheme.rajdhani(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
              Text(
                'KDA',
                style: AppTheme.barlow(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: MockData.statTiles
              .map((s) => _StatTile(stat: s))
              .toList(),
        ),
        const SizedBox(height: 16),
        _PerformanceCard(),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final StatTile stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: AppTheme.rajdhani(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: stat.color,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            stat.label,
            style: AppTheme.barlow(
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE',
            style: AppTheme.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...MockData.statBars.map((b) => _StatBar(bar: b)),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.bar});
  final StatBar bar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bar.label,
                style: AppTheme.barlow(
                  fontSize: 12,
                  color: AppColors.textSubtle,
                ),
              ),
              Text(
                bar.value,
                style: AppTheme.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: bar.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: bar.pct,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(bar.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Results tab ──────────────────────────────────────────────────────────────

class _ResultsTab extends StatelessWidget {
  const _ResultsTab({required this.teamId});
  final String teamId;

  @override
  Widget build(BuildContext context) {
    final results = MockData.resultsForTeam(teamId);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        final opp = MockData.team(r.opponentId);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 42,
                decoration: BoxDecoration(
                  color: r.resultBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  r.result,
                  style: AppTheme.rajdhani(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: r.resultColor,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              ClipPath(
                clipper: _MiniHex(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(gradient: opp.gradient),
                  alignment: Alignment.center,
                  child: Text(
                    opp.mono,
                    style: AppTheme.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${opp.name}',
                      style: AppTheme.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.when,
                      style: AppTheme.barlow(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                r.score,
                style: AppTheme.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniHex extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width * .5, 0)
    ..lineTo(s.width, s.height * .25)
    ..lineTo(s.width, s.height * .75)
    ..lineTo(s.width * .5, s.height)
    ..lineTo(0, s.height * .75)
    ..lineTo(0, s.height * .25)
    ..close();

  @override
  bool shouldReclip(_MiniHex old) => false;
}

// ─── Next match tab ───────────────────────────────────────────────────────────

class _NextMatchTab extends StatelessWidget {
  const _NextMatchTab({required this.teamId});
  final String teamId;

  @override
  Widget build(BuildContext context) {
    final team = MockData.team(teamId);
    final oppId = teamId == 'jdg' ? 'blg' : 'jdg';
    final opp = MockData.team(oppId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-0.6, -1),
              end: Alignment(1, 1),
              colors: [Color(0xD9141C30), Color(0xFF0C1322)],
            ),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 34,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'WORLDS 2025 · GROUP STAGE',
                style: AppTheme.barlow(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(children: [
                      HexLogo(
                          size: 56,
                          gradient: team.gradient,
                          mono: team.mono),
                      const SizedBox(height: 9),
                      Text(
                        team.name,
                        style: AppTheme.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                  Text(
                    'VS',
                    style: AppTheme.rajdhani(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Expanded(
                    child: Column(children: [
                      HexLogo(
                          size: 56,
                          gradient: opp.gradient,
                          mono: opp.mono),
                      const SizedBox(height: 9),
                      Text(
                        opp.name,
                        style: AppTheme.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Jun 20 · 19:00 KST · Seoul',
                style: AppTheme.barlow(
                  fontSize: 13,
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final c in [
              ('02', 'DAYS'),
              ('14', 'HRS'),
              ('37', 'MIN'),
              ('12', 'SEC'),
            ]) ...[
              Expanded(child: _CountdownTile(value: c.$1, label: c.$2)),
              if (c.$2 != 'SEC') const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _CountdownTile extends StatelessWidget {
  const _CountdownTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.rajdhani(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTheme.barlow(
              fontSize: 9,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
