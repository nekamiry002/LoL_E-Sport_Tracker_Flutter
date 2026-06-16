import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/app_provider.dart';
import '../widgets/hex_logo.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favIds = provider.favorites.toList();

    return Column(
      children: [
        _Header(),
        Expanded(
          child: favIds.isEmpty
              ? _EmptyState()
              : _FavoritesList(favIds: favIds),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final count = context.watch<AppProvider>().favorites.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Row(
        children: [
          _HamburgerBtn(),
          Expanded(
            child: Column(
              children: [
                Text(
                  'FAVORITES',
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count TEAMS FOLLOWED',
                  style: AppTheme.rajdhani(
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Icon(Icons.star, color: AppColors.primary, size: 22),
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
          children: [
            _Bar(color: AppColors.primary),
            const SizedBox(height: 4),
            _Bar(color: AppColors.textPrimary),
            const SizedBox(height: 4),
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

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.favIds});
  final List<String> favIds;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 26),
      itemCount: favIds.length,
      itemBuilder: (_, i) {
        final team = MockData.team(favIds[i]);
        return _FavoriteCard(team: team);
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.team});
  final TeamData team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, '/team', arguments: team.id),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, Colors.transparent],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Row(
                  children: [
                    HexLogo(size: 50, gradient: team.gradient, mono: team.mono),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: AppTheme.rajdhani(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(children: [
                            const Icon(
                              Icons.access_time,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              team.nextMatch,
                              style: AppTheme.barlow(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context
                          .read<AppProvider>()
                          .toggleFavorite(team.id),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.star,
                          size: 22,
                          color: AppColors.primary,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HexIllustration(),
            const SizedBox(height: 14),
            Text(
              'NO FAVORITES YET',
              style: AppTheme.rajdhani(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the star on any team to follow them. Their next matches and rosters will live right here.',
              textAlign: TextAlign.center,
              style: AppTheme.barlow(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: () => context.read<AppProvider>().goHome(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  'BROWSE TEAMS',
                  style: AppTheme.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.background,
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

class _HexIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ClipPath(
            clipper: _HexClip(),
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.accent.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: ClipPath(
                clipper: _HexClip(),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  color: const Color(0xFF0C1322),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.star_outline,
                    size: 46,
                    color: AppColors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 8,
            child: ClipPath(
              clipper: _HexClip(),
              child: Container(
                width: 18,
                height: 18,
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 4,
            child: ClipPath(
              clipper: _HexClip(),
              child: Container(
                width: 13,
                height: 13,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HexClip extends CustomClipper<Path> {
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
  bool shouldReclip(_HexClip old) => false;
}
