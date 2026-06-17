import 'package:flutter/material.dart';
import '../domain/entities/user_data.dart';
import '../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  UserData? _user;
  bool _isLoading = true;
  String? _error;

  UserData? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Restores session from persistent storage. Call once at startup.
  Future<void> init() async {
    _user = await _repository.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _error = null;
    try {
      _user = await _repository.login(email, password);
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> register(
      String username, String email, String password) async {
    _error = null;
    try {
      _user = await _repository.register(username, email, password);
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
