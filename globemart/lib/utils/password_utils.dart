import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  // Hash password
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Compare password
  static bool verifyPassword(String password, String hash) {
    final hashed = hashPassword(password);
    return hashed == hash;
  }
}
