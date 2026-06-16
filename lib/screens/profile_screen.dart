import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/hex_pattern.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ProfileHeader(),
          _AvatarSection(),
          _StatsSection(),
          _LeaguesSection(),
          _SettingsSection(),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.07)),
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
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'PROFILE',
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MY ACCOUNT',
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
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 19,
            ),
          ),
        ],
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

class _AvatarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.06,
            child: HexPattern(color: AppColors.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            children: [
              _Avatar(),
              const SizedBox(height: 16),
              Text(
                'SummonerKai',
                style: AppTheme.rajdhani(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 7),
                    Text(
                      'PLATINUM II — LEC FAN',
                      style: AppTheme.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 114,
            height: 114,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 34,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.36, -0.44),
                  radius: 1.0,
                  colors: const [Color(0xFF1B2540), Color(0xFF0A0E1A)],
                ),
                border: Border.all(
                    color: AppColors.background, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                'SK',
                style: AppTheme.rajdhani(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 30),
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E90FF), Color(0xFF0D5778)],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: AppColors.background, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.55),
                    blurRadius: 14,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '87',
                style: AppTheme.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  static const _stats = [
    ('248', 'MATCHES\nFOLLOWED', AppColors.primary),
    ('12', 'TEAMS\nFAVORITED', AppColors.accent),
    ('36', 'NOTIFI-\nCATIONS', AppColors.win),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY STATS',
            style: AppTheme.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: _stats.map((s) {
              final (value, label, color) = s;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: s == _stats.last ? 0 : 10,
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        value,
                        style: AppTheme.rajdhani(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTheme.barlow(
                          fontSize: 9.5,
                          letterSpacing: 1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LeaguesSection extends StatelessWidget {
  static const _leagues = [
    ('LEC', true, AppColors.lecColor),
    ('LCS', false, AppColors.lcsColor),
    ('LCK', false, AppColors.lckColor),
    ('LPL', false, AppColors.lplColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FAVORITE LEAGUES',
            style: AppTheme.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _leagues.map((l) {
                final (name, active, color) = l;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primary,
                              ],
                            )
                          : null,
                      color: active
                          ? null
                          : Colors.white.withValues(alpha: 0.04),
                      border: active
                          ? null
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(children: [
                      ClipPath(
                        clipper: _TinyHex(),
                        child: Container(
                          width: 7,
                          height: 7,
                          color: active ? AppColors.background : color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: AppTheme.rajdhani(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color:
                              active ? AppColors.background : AppColors.textSecondary,
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyHex extends CustomClipper<Path> {
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
  bool shouldReclip(_TinyHex old) => false;
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SETTINGS',
            style: AppTheme.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Opacity(
                    opacity: 0.04,
                    child: HexPattern(color: AppColors.primary),
                  ),
                ),
                Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.notifications_outlined,
                      iconBg: AppColors.primary.withValues(alpha: 0.12),
                      iconColor: AppColors.primary,
                      label: 'Notifications',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted, size: 18),
                    ),
                    _SettingsRow(
                      icon: Icons.language,
                      iconBg: AppColors.accent.withValues(alpha: 0.12),
                      iconColor: AppColors.accent,
                      label: 'Language',
                      trailing: Row(children: [
                        Text(
                          'English',
                          style: AppTheme.barlow(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted, size: 18),
                      ]),
                    ),
                    _SettingsRow(
                      icon: Icons.dark_mode_outlined,
                      iconBg: AppColors.support.withValues(alpha: 0.12),
                      iconColor: AppColors.support,
                      label: 'Dark Mode',
                      trailing: _DarkModeToggle(enabled: provider.darkMode),
                      onTap: provider.toggleDarkMode,
                    ),
                    _SettingsRow(
                      icon: Icons.info_outline,
                      iconBg: AppColors.win.withValues(alpha: 0.12),
                      iconColor: AppColors.win,
                      label: 'About',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted, size: 18),
                    ),
                    _SettingsRow(
                      icon: Icons.logout,
                      iconBg: AppColors.liveRed.withValues(alpha: 0.12),
                      iconColor: AppColors.liveRedLight,
                      label: 'Log Out',
                      labelColor: AppColors.liveRedLight,
                      showDivider: false,
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.labelColor = AppColors.textPrimary,
    this.trailing = const SizedBox.shrink(),
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.barlow(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}

class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              )
            : null,
        color: enabled ? null : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment:
            enabled ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
