import '../entities/user_data.dart';

abstract interface class AuthRepository {
  Future<UserData?> getCurrentUser();
  Future<UserData> login(String email, String password);
  Future<UserData> register(String username, String email, String password);
  Future<void> logout();
}
