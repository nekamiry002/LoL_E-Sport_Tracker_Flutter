import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/app_provider.dart';
import '../widgets/hex_logo.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _region = 'ALL';

  static const _regions = ['ALL', 'LCK', 'LPL', 'LEC', 'LCS'];

  List<TeamData> get _filtered {
    final all = MockData.teams.values.toList();
    if (_region == 'ALL') return all;
    return all.where((t) => t.region == _region).toList();
  }

  @override
  Widget build(BuildContext context) {
    final teams = _filtered;
    return Column(
      children: [
        _Header(total: MockData.teams.length),
        _RegionFilter(
          regions: _regions,
          selected: _region,
          onSelect: (r) => setState(() => _region = r),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: teams.length,
            itemBuilder: (_, i) => _TeamCard(team: teams[i]),
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.total});
  final int total;

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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: AppColors.textSecondary,
              size: 20,
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

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/team', arguments: team.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      team.color1.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () =>
                          context.read<AppProvider>().toggleFavorite(team.id),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isFav ? Icons.star : Icons.star_outline,
                          size: 20,
                          color: isFav
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  HexLogo(
                      size: 68, gradient: team.gradient, mono: team.mono),
                  const SizedBox(height: 12),
                  Text(
                    team.name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: regionColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: regionColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      team.region,
                      style: AppTheme.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: regionColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          team.nextMatch,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTheme.barlow(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
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
