import 'package:flutter/material.dart';
import 'app.dart';
import 'features/auth/auth_factory.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/favorites/favorites_factory.dart';
import 'providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider(createAuthRepository());
  final appProvider = AppProvider(createFavoritesRepository());

  await Future.wait([
    authProvider.init(),
    appProvider.init(),
  ]);

  runApp(App(appProvider: appProvider, authProvider: authProvider));
}
