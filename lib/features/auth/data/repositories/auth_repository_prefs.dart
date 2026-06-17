import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/password_hasher.dart';

/// Web implementation: persists users and session in browser localStorage.
class AuthRepositoryPrefs implements AuthRepository {
  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session_user_id';

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  // ── AuthRepository ─────────────────────────────────────────────────────────

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
    final hashed = PasswordHasher.hash(password, email: email);
    final match = users
        .where((u) => u['email'] == email && u['password'] == hashed)
        .firstOrNull;
    if (match == null) throw Exception('Email ou mot de passe incorrect.');
    final user = _fromMap(match);
    final prefs = await _prefs;
    await prefs.setInt(_sessionKey, user.id);
    return user;
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
      'password': PasswordHasher.hash(password, email: email),
      'created_at': now.millisecondsSinceEpoch,
    };
    users.add(newUser);
    await _saveUsers(users);
    final prefs = await _prefs;
    await prefs.setInt(_sessionKey, id);
    return UserData(id: id, username: username, email: email, createdAt: now);
  }

  @override
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
  }
}
