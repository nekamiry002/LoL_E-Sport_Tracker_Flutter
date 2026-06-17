import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/matches/matches_setup.dart';
import 'providers/app_provider.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/team_detail_screen.dart';
import 'widgets/app_drawer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: matchProviders(
        child: MaterialApp(
        title: 'LOL Esport Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        onGenerateRoute: _routes,
        home: const _MainShell(),
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

class _MainShell extends StatefulWidget {
  const _MainShell();

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
