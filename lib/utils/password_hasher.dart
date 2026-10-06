// lib/utils/password_hasher.dart
// Utility untuk hashing password menggunakan SHA-256
// Menggantikan penyimpanan password plaintext

import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  /// Hash password menggunakan SHA-256
  static String hash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi password terhadap hash yang tersimpan
  static bool verify(String password, String hashedPassword) {
    return hash(password) == hashedPassword;
  }
}
