import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../features/matches/data/datasources/team_remote_datasource.dart';
import '../features/matches/presentation/providers/match_provider.dart';
import '../features/matches/presentation/providers/roster_provider.dart';
import '../features/matches/presentation/providers/team_schedule_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/hex_logo.dart';
import '../widgets/hex_pattern.dart';

class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final team = context.read<MatchProvider>().teamFor(teamId);
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
          _StatsTab(teamId: widget.teamId),
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

class _RosterTab extends StatefulWidget {
  const _RosterTab({required this.teamId});
  final String teamId;

  @override
  State<_RosterTab> createState() => _RosterTabState();
}

class _RosterTabState extends State<_RosterTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final team = context.read<MatchProvider>().teamFor(widget.teamId);
      context.read<RosterProvider>().fetchRoster(team.apiId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final team = context.read<MatchProvider>().teamFor(widget.teamId);
    final roster = context.watch<RosterProvider>();
    final status = roster.statusFor(team.apiId);
    final players = roster.playersFor(team.apiId);

    if (team.apiId.isEmpty) {
      return _UnavailableTab(icon: Icons.people_outline, message: 'Team not found in API.');
    }

    return switch (status) {
      RosterStatus.initial || RosterStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      RosterStatus.failure => _UnavailableTab(
          icon: Icons.people_outline,
          message: roster.errorFor(team.apiId) ?? 'Failed to load roster.',
        ),
      RosterStatus.success => players.isEmpty
          ? _UnavailableTab(icon: Icons.people_outline, message: 'No players found.')
          : ListView.builder(
              primary: false,
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (_, i) => _PlayerCard(player: players[i]),
            ),
    };
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player});
  final PlayerModel player;

  String get _roleGlyph => switch (player.role) {
        'top' => '▲',
        'jungle' => '❖',
        'mid' => '◆',
        'bottom' => '▼',
        'support' => '✚',
        _ => '?',
      };

  Color get _roleColor => switch (player.role) {
        'top' => AppColors.primaryLight,
        'jungle' => AppColors.win,
        'mid' => AppColors.accent,
        'bottom' => AppColors.liveRedLight,
        'support' => AppColors.support,
        _ => AppColors.textMuted,
      };

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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.hardEdge,
            child: player.imageUrl.isNotEmpty &&
                    !player.imageUrl.contains('default-headshot')
                ? Image.network(player.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (context, e, stack) => _initials())
                : _initials(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.summonerName,
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _roleColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(_roleGlyph,
                        style: TextStyle(fontSize: 11, color: _roleColor, height: 1)),
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
          if (player.firstName.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  player.firstName,
                  style: AppTheme.barlow(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  player.lastName,
                  style: AppTheme.barlow(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _initials() => Center(
        child: Text(
          player.summonerName.isNotEmpty
              ? player.summonerName.substring(0, player.summonerName.length.clamp(0, 2)).toUpperCase()
              : '?',
          style: AppTheme.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
}

// ─── Stats tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatefulWidget {
  const _StatsTab({required this.teamId});
  final String teamId;

  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamScheduleProvider>().fetchForTeam(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamScheduleProvider>();
    final state = provider.stateFor(widget.teamId);

    if (state.status == ScheduleStatus.loading ||
        state.status == ScheduleStatus.initial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.status == ScheduleStatus.failure) {
      return _UnavailableTab(
        icon: Icons.bar_chart_outlined,
        message: state.error ?? 'Failed to load stats.',
      );
    }

    final record = state.record;
    if (record == null && state.results.isEmpty) {
      return _UnavailableTab(
        icon: Icons.bar_chart_outlined,
        message: 'No stats available for this team in the current season.',
      );
    }

    final wins = record?.wins ?? 0;
    final losses = record?.losses ?? 0;
    final total = wins + losses;
    final winRate = total > 0 ? (wins / total * 100).round() : 0;

    // Compute current streak from sorted results (most recent first)
    var streak = 0;
    String streakType = '';
    for (final m in state.results) {
      final outcome = m.myOutcome;
      if (streakType.isEmpty) {
        streakType = outcome;
        streak = 1;
      } else if (outcome == streakType) {
        streak++;
      } else {
        break;
      }
    }

    return ListView(
      primary: false,
      padding: const EdgeInsets.all(16),
      children: [
        // Win rate bar card
        _StatCard(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WIN RATE',
                  style: AppTheme.barlow(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$winRate%',
                  style: AppTheme.rajdhani(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: winRate >= 50 ? AppColors.win : AppColors.liveRedLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? wins / total : 0,
                minHeight: 8,
                backgroundColor: AppColors.liveRed.withValues(alpha: 0.25),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.win),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$wins W',
                  style: AppTheme.barlow(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.win,
                  ),
                ),
                Text(
                  '$losses L',
                  style: AppTheme.barlow(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.liveRedLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _StatCard(
              children: [
                Text(
                  'GAMES',
                  style: AppTheme.barlow(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$total',
                  style: AppTheme.rajdhani(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (streak > 0)
            Expanded(
              child: _StatCard(
                children: [
                  Text(
                    'STREAK',
                    style: AppTheme.barlow(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${streakType == 'win' ? 'W' : 'L'}$streak',
                    style: AppTheme.rajdhani(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: streakType == 'win'
                          ? AppColors.win
                          : AppColors.liveRedLight,
                    ),
                  ),
                ],
              ),
            ),
        ]),
        const SizedBox(height: 20),
        Text(
          'Based on season record from the lolesports API.',
          style: AppTheme.barlow(
            fontSize: 11,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.children});
  final List<Widget> children;

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
        children: children,
      ),
    );
  }
}

// ─── Results tab ──────────────────────────────────────────────────────────────

class _ResultsTab extends StatefulWidget {
  const _ResultsTab({required this.teamId});
  final String teamId;

  @override
  State<_ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<_ResultsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamScheduleProvider>().fetchForTeam(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamScheduleProvider>();
    final state = provider.stateFor(widget.teamId);

    if (state.status == ScheduleStatus.loading ||
        state.status == ScheduleStatus.initial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.status == ScheduleStatus.failure) {
      return _UnavailableTab(
        icon: Icons.history,
        message: state.error ?? 'Failed to load results.',
      );
    }

    if (state.results.isEmpty) {
      return _UnavailableTab(
        icon: Icons.history,
        message: 'No completed matches found for this team.',
      );
    }

    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length,
      itemBuilder: (_, i) {
        final m = state.results[i];
        final won = m.myOutcome == 'win';
        final resultLetter = won ? 'W' : 'L';
        final resultColor = won ? AppColors.win : AppColors.liveRedLight;
        final resultBg = won
            ? AppColors.win.withValues(alpha: 0.14)
            : AppColors.liveRed.withValues(alpha: 0.14);
        final matchDate = _formatResultDate(m.startTime);

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
                  color: resultBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  resultLetter,
                  style: AppTheme.rajdhani(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: resultColor,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              _OppBadge(code: m.oppCode, imageUrl: m.oppImage),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${m.oppName}',
                      style: AppTheme.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.leagueName} · $matchDate',
                      style: AppTheme.barlow(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${m.myWins} - ${m.oppWins}',
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

  String _formatResultDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}';
  }
}

class _OppBadge extends StatelessWidget {
  const _OppBadge({required this.code, required this.imageUrl});
  final String code;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.read<MatchProvider>();
    final team = matchProvider.teamFor(code);
    return ClipPath(
      clipper: _MiniHex(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(gradient: team.gradient),
        alignment: Alignment.center,
        child: Text(
          team.mono,
          style: AppTheme.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
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
    final provider = context.watch<MatchProvider>();
    final team = provider.teamFor(teamId);

    final next = provider.displayMatches.where(
      (m) => !m.isCompleted &&
          (m.team1Id == teamId || m.team2Id == teamId),
    ).firstOrNull;

    if (next == null) {
      return _UnavailableTab(
        icon: Icons.event_outlined,
        message: 'No upcoming match found for this team.',
      );
    }

    final oppId = next.team1Id == teamId ? next.team2Id : next.team1Id;
    final opp = provider.teamFor(oppId);

    return ListView(
      primary: false,
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
                '${next.league} · ${next.bo}',
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
                      HexLogo(size: 56, gradient: team.gradient, mono: team.mono),
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
                      HexLogo(size: 56, gradient: opp.gradient, mono: opp.mono),
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
                next.scheduledText ?? '',
                style: AppTheme.barlow(
                  fontSize: 13,
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnavailableTab extends StatelessWidget {
  const _UnavailableTab({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSubtle, size: 44),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.barlow(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
