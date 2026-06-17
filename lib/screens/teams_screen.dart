import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../features/matches/presentation/providers/match_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/team_logo.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _region = 'ALL';
  String _search = '';
  bool _showSearch = false;
  final _searchController = TextEditingController();

  static const _regions = ['ALL', 'LCK', 'LPL', 'LEC', 'LCS'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MatchProvider>();
      if (provider.teamRegistry.isEmpty) provider.fetchMatches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeamData> _filtered(Map<String, TeamData> registry) {
    var all = registry.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    if (_region != 'ALL') all = all.where((t) => t.region == _region).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      all = all.where((t) =>
        t.name.toLowerCase().contains(q) || t.id.toLowerCase().contains(q)
      ).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final registry = matchProvider.teamRegistry;
    final teams = _filtered(registry);
    return Column(
      children: [
        _Header(
          total: registry.length,
          showSearch: _showSearch,
          onSearchToggle: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _search = '';
                _searchController.clear();
              }
            });
          },
        ),
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTheme.rajdhani(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search teams...',
                hintStyle: AppTheme.rajdhani(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        _RegionFilter(
          regions: _regions,
          selected: _region,
          onSelect: (r) => setState(() => _region = r),
        ),
        if (registry.isEmpty && matchProvider.status == MatchesStatus.loading)
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          )
        else if (teams.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No teams found.', style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: const Color(0xFF1A1A2E),
            onRefresh: () => matchProvider.fetchMatches(),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.9,
              ),
              itemCount: teams.length,
              itemBuilder: (_, i) => _TeamCard(team: teams[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.showSearch,
    required this.onSearchToggle,
  });
  final int total;
  final bool showSearch;
  final VoidCallback onSearchToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Row(
        children: [
          _HamburgerBtn(),
          Expanded(
            child: Column(
              children: [
                Text(
                  'TEAMS',
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total TEAMS · SEASON 15',
                  style: AppTheme.rajdhani(
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSearchToggle,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: showSearch
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: showSearch
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.07),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                showSearch ? Icons.close : Icons.search,
                color: showSearch ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HamburgerBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Bar(color: AppColors.primary),
            SizedBox(height: 4),
            _Bar(color: AppColors.textPrimary),
            SizedBox(height: 4),
            _Bar(color: AppColors.textPrimary, width: 12),
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

// ── Region filter chips ───────────────────────────────────────────────────────

class _RegionFilter extends StatelessWidget {
  const _RegionFilter({
    required this.regions,
    required this.selected,
    required this.onSelect,
  });
  final List<String> regions;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final r = regions[i];
          final active = r == selected;
          final color =
              r == 'ALL' ? AppColors.primary : AppColors.leagueColor(r);
          return GestureDetector(
            onTap: () => onSelect(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? color.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: active
                      ? color.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.07),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                r,
                style: AppTheme.rajdhani(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.5,
                  color: active ? color : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Team card (grid cell) ─────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});
  final TeamData team;

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<AppProvider>().isFavorite(team.id);
    final regionColor = AppColors.leagueColor(team.region);
    final matches = context.read<MatchProvider>().displayMatches;

    // Find next/live match for this team
    final liveMatch = matches.where((m) =>
      m.isLive && (m.team1Id == team.id || m.team2Id == team.id)
    ).firstOrNull;
    final nextMatch = matches.where((m) =>
      !m.isCompleted && !m.isLive &&
      (m.team1Id == team.id || m.team2Id == team.id)
    ).firstOrNull;

    String? opponentCode;
    String? matchInfo;
    bool isLive = false;

    if (liveMatch != null) {
      isLive = true;
      opponentCode = liveMatch.team1Id == team.id ? liveMatch.team2Id : liveMatch.team1Id;
      matchInfo = 'LIVE NOW';
    } else if (nextMatch != null) {
      opponentCode = nextMatch.team1Id == team.id ? nextMatch.team2Id : nextMatch.team1Id;
      matchInfo = nextMatch.scheduledText ?? '';
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/team', arguments: team.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: isLive
                ? AppColors.liveRed.withValues(alpha: 0.5)
                : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Color glow top-right
            Positioned(
              top: -16,
              right: -16,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [team.color1.withValues(alpha: 0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: region badge + star
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: regionColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: regionColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          team.region,
                          style: AppTheme.rajdhani(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: regionColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.read<AppProvider>().toggleFavorite(team.id),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            isFav ? Icons.star : Icons.star_outline,
                            size: 15,
                            color: isFav ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Middle: logo + name
                  Row(
                    children: [
                      TeamLogo(team: team, size: 26),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          team.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTheme.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom: match info
                  if (matchInfo != null)
                    Row(
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.liveRedLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('LIVE', style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            letterSpacing: 1, color: AppColors.liveRedLight,
                          )),
                        ] else ...[
                          const Icon(Icons.access_time, size: 9, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(matchInfo,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTheme.barlow(fontSize: 9, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                        if (opponentCode != null) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text('vs $opponentCode',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTheme.rajdhani(
                                fontSize: 9, fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Text('No upcoming match',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTheme.barlow(fontSize: 9, color: AppColors.textSubtle),
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
