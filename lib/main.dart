import 'package:flutter/material.dart';
import 'app.dart';
import 'features/auth/auth_factory.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/favorites/favorites_factory.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider(createAuthRepository());
  final appProvider = AppProvider(createFavoritesRepository());
  final notificationPrefs = NotificationPrefsProvider();
  final languageProvider = LanguageProvider();

  await Future.wait([
    authProvider.init(),
    appProvider.init(),
    notificationPrefs.init(),
    languageProvider.init(),
  ]);

  runApp(App(
    appProvider: appProvider,
    authProvider: authProvider,
    notificationPrefs: notificationPrefs,
    languageProvider: languageProvider,
  ));
}
