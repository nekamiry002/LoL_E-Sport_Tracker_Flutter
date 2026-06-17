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
    final hashed = PasswordHasher.hash(password, email: email);
    final row = await _datasource.findByEmailAndPassword(email, hashed);
    if (row == null) throw Exception('Email ou mot de passe incorrect.');
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
    final hashed = PasswordHasher.hash(password, email: email);
    final now = DateTime.now();
    final id = await _datasource.createUser(
      username: username,
      email: email,
      hashedPassword: hashed,
      createdAt: now.millisecondsSinceEpoch,
    );
    await _datasource.saveSession(id);
    return UserData(id: id, username: username, email: email, createdAt: now);
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
