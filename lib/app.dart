import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/matches/matches_setup.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/team_detail_screen.dart';
import 'screens/teams_screen.dart';
import 'widgets/app_drawer.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.appProvider,
    required this.authProvider,
  });

  final AppProvider appProvider;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: appProvider),
      ],
      child: matchProviders(
        child: MaterialApp(
          title: 'LOL Esport Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          scrollBehavior: const _MobileScrollBehavior(),
          onGenerateRoute: _routes,
          home: const _AppGate(),
        ),
      ),
    );
  }

  static Route<dynamic>? _routes(RouteSettings settings) {
    if (settings.name == '/team') {
      final teamId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => TeamDetailScreen(teamId: teamId),
      );
    }
    return null;
  }
}

class _MobileScrollBehavior extends MaterialScrollBehavior {
  const _MobileScrollBehavior();

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// ── Auth gate: splash → auth flow → main app ──────────────────────────────────

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) return const _SplashScreen();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: auth.isAuthenticated
          ? const _MainShell(key: ValueKey('main'))
          : const _AuthGate(key: ValueKey('auth')),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// Switches between LoginScreen and RegisterScreen without using Navigator,
// so auth → main transition works cleanly.
class _AuthGate extends StatefulWidget {
  const _AuthGate({super.key});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _showRegister
          ? RegisterScreen(
              key: const ValueKey('register'),
              onGoToLogin: () => setState(() => _showRegister = false),
            )
          : LoginScreen(
              key: const ValueKey('login'),
              onGoToRegister: () => setState(() => _showRegister = true),
            ),
    );
  }
}

// ── Main shell ────────────────────────────────────────────────────────────────

class _MainShell extends StatefulWidget {
  const _MainShell({super.key});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.watch<AppProvider>().screen;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (screen) {
            AppScreen.home => const HomeScreen(key: ValueKey('home')),
            AppScreen.history =>
              const HistoryScreen(key: ValueKey('history')),
            AppScreen.teams => const TeamsScreen(key: ValueKey('teams')),
            AppScreen.favorites =>
              const FavoritesScreen(key: ValueKey('favorites')),
            AppScreen.profile =>
              const ProfileScreen(key: ValueKey('profile')),
          },
        ),
      ),
    );
  }
}
