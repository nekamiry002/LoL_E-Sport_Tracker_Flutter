import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/password_hasher.dart';

/// Web / macOS implementation: persists users and session in SharedPreferences.
class AuthRepositoryPrefs implements AuthRepository {
  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session_user_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  UserData _fromMap(Map<String, dynamic> m) => UserData(
        id: m['id'] as int,
        username: m['username'] as String,
        email: m['email'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );

  @override
  Future<UserData?> getCurrentUser() async {
    final prefs = await _prefs;
    final userId = prefs.getInt(_sessionKey);
    if (userId == null) return null;
    final users = await _loadUsers();
    final match = users.where((u) => u['id'] == userId).firstOrNull;
    return match == null ? null : _fromMap(match);
  }

  @override
  Future<UserData> login(String email, String password) async {
    final users = await _loadUsers();
    final byEmail = users.where((u) => u['email'] == email).firstOrNull;
    if (byEmail == null) throw Exception('Email ou mot de passe incorrect.');

    final id = byEmail['id'] as int;

    // Try new hash (by userId) first, then legacy (by email) for old accounts.
    final newHash = PasswordHasher.hash(password, userId: id);
    final legacyHash = PasswordHasher.hashLegacy(password, email: email);
    final stored = byEmail['password'] as String;

    if (stored != newHash && stored != legacyHash) {
      throw Exception('Email ou mot de passe incorrect.');
    }

    // Migrate legacy hash to new format on successful login.
    if (stored == legacyHash) {
      final idx = users.indexOf(byEmail);
      users[idx] = {...byEmail, 'password': newHash};
      await _saveUsers(users);
    }

    final prefs = await _prefs;
    await prefs.setInt(_sessionKey, id);
    return _fromMap(byEmail);
  }

  @override
  Future<UserData> register(
      String username, String email, String password) async {
    final users = await _loadUsers();
    if (users.any((u) => u['email'] == email)) {
      throw Exception('Cet email est déjà utilisé.');
    }
    final id = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();
    final newUser = {
      'id': id,
      'username': username,
      'email': email,
      'password': PasswordHasher.hash(password, userId: id),
      'created_at': now.millisecondsSinceEpoch,
    };
    users.add(newUser);
    await _saveUsers(users);
    final prefs = await _prefs;
    await prefs.setInt(_sessionKey, id);
    return UserData(id: id, username: username, email: email, createdAt: now);
  }

  @override
  Future<UserData> updateUser({String? username, String? email}) async {
    final prefs = await _prefs;
    final userId = prefs.getInt(_sessionKey);
    if (userId == null) throw Exception('Not logged in.');
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u['id'] == userId);
    if (idx == -1) throw Exception('User not found.');
    final old = users[idx];
    users[idx] = {
      ...old,
      ...{
        'username': username,
        'email': email,
      }..removeWhere((_, v) => v == null),
    };
    await _saveUsers(users);
    return _fromMap(users[idx]);
  }

  @override
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
  }
}
