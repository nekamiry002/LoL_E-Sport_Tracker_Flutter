import 'dart:math';

class UserData {
  const UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String email;
  final DateTime createdAt;

  String get initials =>
      username.substring(0, min(2, username.length)).toUpperCase();
}
