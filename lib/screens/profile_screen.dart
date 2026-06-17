import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/matches/presentation/providers/match_provider.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_prefs_provider.dart';
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
          GestureDetector(
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => const _EditProfileDialog(),
            ),
            child: Container(
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

String _formatMonth(DateTime dt) {
  const months = [
    '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];
  return '${months[dt.month]} ${dt.year}';
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
              Builder(builder: (context) {
                final user = context.watch<AuthProvider>().user;
                return Column(
                  children: [
                    Text(
                      user?.username ?? '—',
                      style: AppTheme.rajdhani(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user!.email,
                        style: AppTheme.barlow(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 13),
                          const SizedBox(width: 7),
                          Text(
                            user != null
                                ? 'MEMBER SINCE ${_formatMonth(user.createdAt)}'
                                : '—',
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
                );
              }),
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
                context.watch<AuthProvider>().user?.initials ?? '?',
                style: AppTheme.rajdhani(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primary,
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
  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<AppProvider>().favorites.length;
    final user = context.watch<AuthProvider>().user;
    final memberSince = user != null ? _formatMonth(user.createdAt) : '—';

    final stats = [
      ('$favCount', 'TEAMS\nFAVORITED', AppColors.accent),
      (memberSince, 'MEMBER\nSINCE', AppColors.primary),
    ];

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
            children: stats.asMap().entries.map((e) {
              final i = e.key;
              final (value, label, color) = e.value;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
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
                          fontSize: value.length > 4 ? 20 : 30,
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
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppProvider>().favorites;
    final matchProvider = context.read<MatchProvider>();

    // Collect leagues from favorited teams
    final favoriteLeagues = <String>{};
    for (final teamId in favorites) {
      final team = matchProvider.teamFor(teamId);
      if (team.region.isNotEmpty) favoriteLeagues.add(team.region);
    }

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
          if (favoriteLeagues.isEmpty)
            Text(
              'Add teams to your favorites to see your leagues.',
              style: AppTheme.barlow(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: favoriteLeagues.map((name) {
                        return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(children: [
                        ClipPath(
                          clipper: _TinyHex(),
                          child: Container(
                            width: 7,
                            height: 7,
                            color: AppColors.background,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: AppTheme.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.background,
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

void _showNotificationsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const _NotificationsDialog(),
  );
}

void _showLanguageDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const _LanguageDialog(),
  );
}

void _showAboutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const _AboutAppDialog(),
  );
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
                      onTap: () => _showNotificationsDialog(context),
                    ),
                    _SettingsRow(
                      icon: Icons.language,
                      iconBg: AppColors.accent.withValues(alpha: 0.12),
                      iconColor: AppColors.accent,
                      label: 'Language',
                      trailing: Row(children: [
                        Text(
                          context.watch<LanguageProvider>().selected,
                          style: AppTheme.barlow(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted, size: 18),
                      ]),
                      onTap: () => _showLanguageDialog(context),
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
                      onTap: () => _showAboutDialog(context),
                    ),
                    _SettingsRow(
                      icon: Icons.logout,
                      iconBg: AppColors.liveRed.withValues(alpha: 0.12),
                      iconColor: AppColors.liveRedLight,
                      label: 'Log Out',
                      labelColor: AppColors.liveRedLight,
                      showDivider: false,
                      onTap: () =>
                          context.read<AuthProvider>().logout(),
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

// ─── Edit profile dialog ──────────────────────────────────────────────────────

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog();

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newUsername = _usernameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();
    if (newUsername.isEmpty || newEmail.isEmpty) {
      setState(() => _error = 'Fields cannot be empty.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final ok = await context.read<AuthProvider>().updateUser(
      username: newUsername,
      email: newEmail,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = context.read<AuthProvider>().error ?? 'Update failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AppDialog(
      title: 'EDIT PROFILE',
      icon: Icons.edit_outlined,
      iconColor: AppColors.primary,
      children: [
        _InputField(
          label: 'Username',
          controller: _usernameCtrl,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _InputField(
          label: 'Email',
          controller: _emailCtrl,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: AppTheme.barlow(fontSize: 13, color: AppColors.liveRedLight),
          ),
        ],
        const SizedBox(height: 20),
        _saving
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
            : _DialogButton(label: 'SAVE', onTap: _save),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.barlow(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTheme.barlow(fontSize: 15, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  cursorColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Dialogs ──────────────────────────────────────────────────────────────────

class _NotificationsDialog extends StatefulWidget {
  const _NotificationsDialog();

  @override
  State<_NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<_NotificationsDialog> {
  late bool _matchStart;
  late bool _matchEnd;
  late bool _liveUpdates;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<NotificationPrefsProvider>();
    _matchStart = prefs.matchStart;
    _matchEnd = prefs.matchEnd;
    _liveUpdates = prefs.liveUpdates;
  }

  @override
  Widget build(BuildContext context) {
    return _AppDialog(
      title: 'NOTIFICATIONS',
      icon: Icons.notifications_outlined,
      iconColor: AppColors.primary,
      children: [
        _SwitchRow(
          label: 'Match start',
          subtitle: 'Alert when a match begins',
          value: _matchStart,
          onChanged: (v) => setState(() => _matchStart = v),
        ),
        _SwitchRow(
          label: 'Match result',
          subtitle: 'Alert when a match ends',
          value: _matchEnd,
          onChanged: (v) => setState(() => _matchEnd = v),
        ),
        _SwitchRow(
          label: 'Live score updates',
          subtitle: 'Updates during the match',
          value: _liveUpdates,
          onChanged: (v) => setState(() => _liveUpdates = v),
        ),
        const SizedBox(height: 8),
        _DialogButton(
          label: 'SAVE',
          onTap: () {
            context.read<NotificationPrefsProvider>().save(
                  matchStart: _matchStart,
                  matchEnd: _matchEnd,
                  liveUpdates: _liveUpdates,
                );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _LanguageDialog extends StatefulWidget {
  const _LanguageDialog();

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  late String _selected;

  static const _languages = ['English', 'Français', 'Español', '한국어', '中文'];

  @override
  void initState() {
    super.initState();
    _selected = context.read<LanguageProvider>().selected;
  }

  @override
  Widget build(BuildContext context) {
    return _AppDialog(
      title: 'LANGUAGE',
      icon: Icons.language,
      iconColor: AppColors.accent,
      children: [
        ..._languages.map((lang) => GestureDetector(
              onTap: () => setState(() => _selected = lang),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang,
                        style: AppTheme.barlow(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _selected == lang
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_selected == lang)
                      const Icon(Icons.check,
                          color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 8),
        _DialogButton(
          label: 'CONFIRM',
          onTap: () {
            context.read<LanguageProvider>().setLanguage(_selected);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _AboutAppDialog extends StatelessWidget {
  const _AboutAppDialog();

  @override
  Widget build(BuildContext context) {
    return _AppDialog(
      title: 'ABOUT',
      icon: Icons.info_outline,
      iconColor: AppColors.win,
      children: [
        Text(
          'LoL Esport Tracker',
          style: AppTheme.rajdhani(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Version 1.0.0',
          style: AppTheme.barlow(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Text(
          'Follow your favorite League of Legends esports teams and matches in real time.',
          style: AppTheme.barlow(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        _InfoRow(label: 'Data', value: 'lolesports.com API'),
        _InfoRow(label: 'Built with', value: 'Flutter'),
        const SizedBox(height: 20),
        _DialogButton(
          label: 'CLOSE',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// ─── Dialog helpers ───────────────────────────────────────────────────────────

class _AppDialog extends StatelessWidget {
  const _AppDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1525),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.rajdhani(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.barlow(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.barlow(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: value
                    ? const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primary])
                    : null,
                color: value ? null : Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        value ? AppColors.background : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.barlow(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTheme.barlow(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.rajdhani(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
