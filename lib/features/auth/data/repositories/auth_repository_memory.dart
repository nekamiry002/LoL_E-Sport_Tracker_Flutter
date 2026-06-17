import '../../domain/entities/user_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/password_hasher.dart';

/// In-memory implementation for web and tests.
class AuthRepositoryMemory implements AuthRepository {
  final List<_UserRecord> _users = [];
  UserData? _currentUser;
  int _nextId = 1;

  @override
  Future<UserData?> getCurrentUser() async => _currentUser;

  @override
  Future<UserData> login(String email, String password) async {
    final record = _users.where((u) => u.email == email).firstOrNull;
    if (record == null) throw Exception('Email ou mot de passe incorrect.');
    final newHash = PasswordHasher.hash(password, userId: record.id);
    final legacyHash = PasswordHasher.hashLegacy(password, email: email);
    if (record.passwordHash != newHash && record.passwordHash != legacyHash) {
      throw Exception('Email ou mot de passe incorrect.');
    }
    _currentUser = record.toUserData();
    return _currentUser!;
  }

  @override
  Future<UserData> register(
      String username, String email, String password) async {
    if (_users.any((u) => u.email == email)) {
      throw Exception('Cet email est déjà utilisé.');
    }
    final id = _nextId++;
    final record = _UserRecord(
      id: id,
      username: username,
      email: email,
      passwordHash: PasswordHasher.hash(password, userId: id),
      createdAt: DateTime.now(),
    );
    _users.add(record);
    _currentUser = record.toUserData();
    return _currentUser!;
  }

  @override
  Future<UserData> updateUser({String? username, String? email}) async {
    if (_currentUser == null) throw Exception('Not logged in.');
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx == -1) throw Exception('User not found.');
    final old = _users[idx];
    final updated = _UserRecord(
      id: old.id,
      username: username ?? old.username,
      email: email ?? old.email,
      passwordHash: old.passwordHash,
      createdAt: old.createdAt,
    );
    _users[idx] = updated;
    _currentUser = updated.toUserData();
    return _currentUser!;
  }

  @override
  Future<void> logout() async => _currentUser = null;
}

class _UserRecord {
  const _UserRecord({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });
  final int id;
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  UserData toUserData() =>
      UserData(id: id, username: username, email: email, createdAt: createdAt);
}
