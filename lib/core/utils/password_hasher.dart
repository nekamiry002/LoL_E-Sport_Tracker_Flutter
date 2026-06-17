import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static const _appSalt = 'lol_esport_s3cr3t_2025';

  /// SHA-256 with a static app salt + user ID as user-specific salt.
  /// Using ID (not email) so email changes don't invalidate the hash.
  static String hash(String password, {required int userId}) {
    final input = '$_appSalt:$userId:$password';
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Legacy hash used during registration/login before userId was known.
  /// Only used to migrate old accounts that stored email-based hashes.
  static String hashLegacy(String password, {required String email}) {
    final input = '$_appSalt:${email.toLowerCase()}:$password';
    return sha256.convert(utf8.encode(input)).toString();
  }
}
