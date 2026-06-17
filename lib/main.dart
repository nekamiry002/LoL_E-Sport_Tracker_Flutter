import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'features/auth/auth_factory.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/favorites/favorites_factory.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_prefs_provider.dart';
import 'services/notification_service.dart';
import 'services/background_task.dart';

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
    NotificationService.instance.init(),
  ]);

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await registerBackgroundTask();
  }

  runApp(App(
    appProvider: appProvider,
    authProvider: authProvider,
    notificationPrefs: notificationPrefs,
    languageProvider: languageProvider,
  ));
}
