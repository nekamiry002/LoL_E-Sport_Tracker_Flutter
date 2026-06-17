import '../entities/user_data.dart';

abstract interface class AuthRepository {
  Future<UserData?> getCurrentUser();
  Future<UserData> login(String email, String password);
  Future<UserData> register(String username, String email, String password);
  Future<UserData> updateUser({String? username, String? email});
  Future<void> logout();
}
