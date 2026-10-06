// lib/utils/validators.dart
// Validasi input terpusat untuk seluruh form di aplikasi

import '../constants/app_strings.dart';

class Validators {
  Validators._();

  /// Validasi NIS: wajib diisi, hanya angka, minimal 4 digit
  static String? validateNIS(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.nisRequired;
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return AppStrings.nisNumericOnly;
    }
    if (value.trim().length < 4) return AppStrings.nisMinLength;
    return null;
  }

  /// Validasi Password: wajib diisi, minimal 6 karakter
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 6) return AppStrings.passwordMinLength;
    return null;
  }

  /// Validasi Konfirmasi Password: harus sama dengan password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != password) return AppStrings.passwordMismatch;
    return null;
  }

  /// Validasi Nama: wajib diisi, minimal 3 karakter
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.nameRequired;
    if (value.trim().length < 3) return AppStrings.nameMinLength;
    return null;
  }

  /// Validasi umum: field wajib diisi
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${AppStrings.fieldRequired}';
    }
    return null;
  }
}
