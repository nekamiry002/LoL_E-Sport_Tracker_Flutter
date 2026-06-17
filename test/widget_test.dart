import 'package:flutter_test/flutter_test.dart';
import 'package:lol_esport_tracker/app.dart';
import 'package:lol_esport_tracker/features/auth/data/repositories/auth_repository_memory.dart';
import 'package:lol_esport_tracker/features/auth/providers/auth_provider.dart';
import 'package:lol_esport_tracker/features/favorites/data/repositories/favorites_repository_memory.dart';
import 'package:lol_esport_tracker/providers/app_provider.dart';

void main() {
  testWidgets(
      'App redirects to login screen when not authenticated',
      (tester) async {
    final authProvider = AuthProvider(AuthRepositoryMemory());
    await authProvider.init();

    final appProvider = AppProvider(FavoritesRepositoryMemory(seed: {}));
    await appProvider.init();

    await tester.pumpWidget(
        App(appProvider: appProvider, authProvider: authProvider));
    await tester.pump();

    // Not authenticated → login screen should show
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });

  testWidgets('App shows main shell after login', (tester) async {
    final repo = AuthRepositoryMemory();
    await repo.register('Tester', 'test@test.com', 'password123');

    final authProvider = AuthProvider(repo);
    await authProvider.init();

    final appProvider = AppProvider(FavoritesRepositoryMemory(seed: {}));
    await appProvider.init();

    await tester.pumpWidget(
        App(appProvider: appProvider, authProvider: authProvider));
    await tester.pump();

    // Authenticated → main shell should show MATCHES
    expect(find.text('MATCHES'), findsOneWidget);
  });
}
