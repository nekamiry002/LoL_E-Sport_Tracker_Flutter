import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_prefs.dart';

AuthRepository createAuthRepository() => AuthRepositoryPrefs();
