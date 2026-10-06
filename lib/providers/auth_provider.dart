// lib/providers/auth_provider.dart
// Provider khusus autentikasi & manajemen user

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../utils/password_hasher.dart';
import '../utils/result.dart';
import '../constants/app_strings.dart';

class AuthProvider with ChangeNotifier {
  final AppRepository _repo;

  AuthProvider(this._repo);

  // ────────────── State ──────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // ────────────── User Queries ──────────────
  List<UserModel> get allUsers => _repo.getAllSiswa();
  List<UserModel> get leaderboard => _repo.getLeaderboard();

  // ────────────── Auth ──────────────

  /// Login dengan NIS dan password.
  /// Mengembalikan [Result] dengan pesan error yang spesifik.
  Result<UserModel> login(String nis, String password) {
    if (nis.trim().isEmpty || password.isEmpty) {
      return const Failure(
        'NIS dan Password tidak boleh kosong',
        code: 'EMPTY_FIELDS',
      );
    }

    final user = _repo.getUserByNis(nis.trim());
    if (user == null) {
      return const Failure(
        'NIS tidak ditemukan',
        code: 'NIS_NOT_FOUND',
      );
    }

    if (!PasswordHasher.verify(password, user.password)) {
      return const Failure(
        'Password salah',
        code: 'WRONG_PASSWORD',
      );
    }

    _currentUser = user;
    notifyListeners();
    return Success(user);
  }

  /// Register user baru.
  /// Password akan di-hash sebelum disimpan.
  Result<UserModel> register({
    required String nis,
    required String name,
    required String kelas,
    required String password,
  }) {
    if (_repo.nisExists(nis.trim())) {
      return const Failure(
        AppStrings.nisAlreadyRegistered,
        code: 'NIS_EXISTS',
      );
    }

    final newUser = UserModel(
      id: 'u${(_repo as dynamic).userCount + 1}',
      nis: nis.trim(),
      password: PasswordHasher.hash(password),
      name: name.trim(),
      kelas: kelas,
      role: 'Siswa',
    );
    _repo.addUser(newUser);
    _currentUser = newUser;
    notifyListeners();
    return Success(newUser);
  }

  /// Logout — hapus session user
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ────────────── Authorization Checks ──────────────

  /// Cek apakah user bisa membalas tiket (Guru/Mentor/Moderator)
  bool canReplyToTicket() {
    if (_currentUser == null) return false;
    if (_currentUser!.role == 'Guru') return true;
    return _currentUser!.activeRole == UserRole.mentor ||
        _currentUser!.activeRole == UserRole.moderator;
  }

  /// Cek apakah user bisa moderasi tiket (Guru/Moderator)
  bool canModerateTicket() {
    if (_currentUser == null) return false;
    if (_currentUser!.role == 'Guru') return true;
    return _currentUser!.activeRole == UserRole.moderator;
  }

  // ────────────── User Updates ──────────────
  // Dipanggil oleh provider lain untuk cross-domain updates

  void addPoin(int amount) {
    if (_currentUser != null) {
      _currentUser!.poin += amount;
      notifyListeners();
    }
  }

  void addPoinToUser(String userId, int amount) {
    final user = _repo.getUserById(userId);
    if (user != null) {
      user.poin += amount;
      notifyListeners();
    }
  }

  void incrementTicketsCreated() {
    if (_currentUser != null) {
      _currentUser!.ticketsCreated += 1;
      notifyListeners();
    }
  }

  void incrementTicketsAnswered() {
    if (_currentUser != null) {
      _currentUser!.ticketsAnswered += 1;
      notifyListeners();
    }
  }

  void addActivity(ActivityItem activity) {
    if (_currentUser != null) {
      _currentUser!.activities.insert(0, activity);
      notifyListeners();
    }
  }
}
