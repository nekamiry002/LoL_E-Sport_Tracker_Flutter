import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../widgets/hex_logo.dart';
import '../../widgets/hex_pattern.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onGoToRegister});
  final VoidCallback onGoToRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _submitting = true);
    await context.read<AuthProvider>().login(email, password);
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthProvider>().error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: HexPattern(color: AppColors.primary),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const AppHexLogo(size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'ESPORT TRACKER',
                    style: AppTheme.rajdhani(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour suivre vos équipes',
                    style: AppTheme.barlow(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 52),
                  _AuthField(
                    controller: _emailCtrl,
                    hint: 'Adresse email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _AuthField(
                    controller: _passwordCtrl,
                    hint: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    trailing: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    _ErrorBanner(error),
                  ],
                  const SizedBox(height: 28),
                  _GoldButton(
                    label: 'SE CONNECTER',
                    loading: _submitting,
                    onTap: _submit,
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ?  ',
                        style: AppTheme.barlow(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onGoToRegister,
                        child: Text(
                          "S'inscrire",
                          style: AppTheme.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Register screen ────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onGoToLogin});
  final VoidCallback onGoToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _localError;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    final validationError = _validate(username, email, password, confirm);
    if (validationError != null) {
      setState(() => _localError = validationError);
      return;
    }
    setState(() {
      _localError = null;
      _submitting = true;
    });
    context.read<AuthProvider>().clearError();
    await context.read<AuthProvider>().register(username, email, password);
    if (mounted) setState(() => _submitting = false);
  }

  String? _validate(
      String username, String email, String password, String confirm) {
    if (username.length < 3) return 'Pseudo : 3 caractères minimum.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Adresse email invalide.';
    }
    if (password.length < 6) return 'Mot de passe : 6 caractères minimum.';
    if (password != confirm) return 'Les mots de passe ne correspondent pas.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final providerError = context.watch<AuthProvider>().error;
    final displayError = _localError ?? providerError;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: HexPattern(color: AppColors.primary),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: 0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 52),
                  const AppHexLogo(size: 72),
                  const SizedBox(height: 18),
                  Text(
                    'CRÉER UN COMPTE',
                    style: AppTheme.rajdhani(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rejoignez la communauté esport',
                    style: AppTheme.barlow(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 44),
                  _AuthField(
                    controller: _usernameCtrl,
                    hint: 'Pseudo',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _AuthField(
                    controller: _emailCtrl,
                    hint: 'Adresse email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _AuthField(
                    controller: _passwordCtrl,
                    hint: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    trailing: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AuthField(
                    controller: _confirmCtrl,
                    hint: 'Confirmer le mot de passe',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (displayError != null) ...[
                    const SizedBox(height: 14),
                    _ErrorBanner(displayError),
                  ],
                  const SizedBox(height: 28),
                  _GoldButton(
                    label: "S'INSCRIRE",
                    loading: _submitting,
                    onTap: _submit,
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ?  ',
                        style: AppTheme.barlow(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onGoToLogin,
                        child: Text(
                          'Se connecter',
                          style: AppTheme.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              onSubmitted: onSubmitted,
              style: AppTheme.barlow(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTheme.barlow(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.background,
                  ),
                )
              : Text(
                  label,
                  style: AppTheme.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.background,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.liveRed.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.liveRedLight, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTheme.barlow(
                fontSize: 13,
                color: AppColors.liveRedLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
