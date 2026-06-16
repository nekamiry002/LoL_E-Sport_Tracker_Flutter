import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'hex_logo.dart';
import 'hex_pattern.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final screen = provider.screen;

    return Drawer(
      width: 286,
      backgroundColor: AppColors.surfaceDeep,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -1),
                  radius: 1.2,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: HexPattern(
              color: AppColors.primary,
              opacity: 0.07,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DrawerHeader(),
                const Divider(
                  color: AppColors.primary,
                  thickness: 0,
                  indent: 22,
                  endIndent: 22,
                  height: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 18),
                    child: Column(
                      children: [
                        _NavItem(
                          icon: Icons.home_outlined,
                          label: 'HOME',
                          isActive: screen == AppScreen.home,
                          onTap: () {
                            context.read<AppProvider>().goHome();
                            Navigator.pop(context);
                          },
                        ),
                        _NavItem(
                          icon: Icons.history,
                          label: 'HISTORY',
                          isActive: false,
                          onTap: () {
                            context.read<AppProvider>().goHome();
                            Navigator.pop(context);
                          },
                        ),
                        _NavItem(
                          icon: Icons.groups_outlined,
                          label: 'TEAMS',
                          isActive: false,
                          onTap: () {
                            context.read<AppProvider>().goHome();
                            Navigator.pop(context);
                          },
                        ),
                        _NavItem(
                          icon: Icons.star_outline,
                          label: 'FAVORITES',
                          isActive: screen == AppScreen.favorites,
                          onTap: () {
                            context.read<AppProvider>().goFavorites();
                            Navigator.pop(context);
                          },
                        ),
                        _NavItem(
                          icon: Icons.person_outline,
                          label: 'PROFILE',
                          isActive: screen == AppScreen.profile,
                          onTap: () {
                            context.read<AppProvider>().goProfile();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: Colors.white.withValues(alpha: 0.06),
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'v2.4.1 · Season 15 Split 2',
                        style: GoogleFonts.barlow(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: AppColors.textMuted,
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
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 42, 22, 22),
      child: Row(
        children: [
          const AppHexLogo(size: 46),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESPORT',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 3,
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),
              Text(
                'TRACKER',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppColors.primaryLight : AppColors.textSubtle;
    final bg = isActive
        ? AppColors.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isActive)
                Positioned(
                  left: -16,
                  top: 0,
                  bottom: 0,
                  width: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 15),
                  Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      letterSpacing: 1.5,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
