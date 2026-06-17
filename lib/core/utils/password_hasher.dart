import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static const _appSalt = 'lol_esport_s3cr3t_2025';

  /// SHA-256 with a static app salt + email as user-specific salt.
  static String hash(String password, {required String email}) {
    final input = '$_appSalt:${email.toLowerCase()}:$password';
    return sha256.convert(utf8.encode(input)).toString();
  }
}
