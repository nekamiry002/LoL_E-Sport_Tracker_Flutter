import '../../domain/entities/user_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/password_hasher.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthLocalDatasource? datasource})
      : _datasource = datasource ?? AuthLocalDatasource();

  final AuthLocalDatasource _datasource;

  @override
  Future<UserData?> getCurrentUser() async {
    final id = await _datasource.getCurrentUserId();
    if (id == null) return null;
    final row = await _datasource.getUserById(id);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<UserData> login(String email, String password) async {
    // Find user by email only first to get the ID for hashing.
    final row = await _datasource.findByEmail(email);
    if (row == null) throw Exception('Email ou mot de passe incorrect.');
    final id = row['id'] as int;
    final newHash = PasswordHasher.hash(password, userId: id);
    final legacyHash = PasswordHasher.hashLegacy(password, email: email);
    final stored = row['password'] as String;
    if (stored != newHash && stored != legacyHash) {
      throw Exception('Email ou mot de passe incorrect.');
    }
    // Migrate legacy hash transparently.
    if (stored == legacyHash) {
      await _datasource.updatePassword(id, newHash);
    }
    final user = _fromRow(row);
    await _datasource.saveSession(user.id);
    return user;
  }

  @override
  Future<UserData> register(
      String username, String email, String password) async {
    if (await _datasource.emailExists(email)) {
      throw Exception('Cet email est déjà utilisé.');
    }
    final now = DateTime.now();
    // Create with a placeholder hash, then update with ID-based hash.
    final id = await _datasource.createUser(
      username: username,
      email: email,
      hashedPassword: '',
      createdAt: now.millisecondsSinceEpoch,
    );
    final hashed = PasswordHasher.hash(password, userId: id);
    await _datasource.updatePassword(id, hashed);
    await _datasource.saveSession(id);
    return UserData(id: id, username: username, email: email, createdAt: now);
  }

  @override
  Future<UserData> updateUser({String? username, String? email}) async {
    final id = await _datasource.getCurrentUserId();
    if (id == null) throw Exception('Not logged in.');
    await _datasource.updateUser(id, username: username, email: email);
    final row = await _datasource.getUserById(id);
    return _fromRow(row!);
  }

  @override
  Future<void> logout() => _datasource.clearSession();

  UserData _fromRow(Map<String, dynamic> row) => UserData(
        id: row['id'] as int,
        username: row['username'] as String,
        email: row['email'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
}
