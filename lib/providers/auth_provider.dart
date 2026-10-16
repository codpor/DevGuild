// lib/providers/auth_provider.dart
// Provider khusus autentikasi & manajemen user

import '../repositories/repository_notifier.dart';

import '../models/models.dart';
import '../models/local_image.dart';
import '../repositories/app_repository.dart';
import '../utils/password_hasher.dart';
import '../utils/result.dart';
import '../constants/app_strings.dart';
import '../services/badge_service.dart';
import '../utils/validators.dart';

class AuthProvider extends RepositoryNotifier {
  final AppRepository _repo;

  AuthProvider(this._repo) : super(_repo);

  // ────────────── State ──────────────
  UserModel? _currentUser;
  UserModel? get currentUser =>
      _currentUser?.isActive == true ? _currentUser : null;
  bool get canManageStudents => currentUser?.role == 'Guru';

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
      return const Failure('NIS tidak ditemukan', code: 'NIS_NOT_FOUND');
    }

    if (!PasswordHasher.verify(password, user.password)) {
      return const Failure('Password salah', code: 'WRONG_PASSWORD');
    }

    if (!user.isActive) {
      return const Failure(
        'Akun nonaktif. Hubungi guru untuk mengaktifkan kembali.',
        code: 'ACCOUNT_INACTIVE',
      );
    }
    _currentUser = user;
    _awardBadges(user);
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
    final validationError =
        Validators.validateNIS(nis) ??
        Validators.validateName(name) ??
        Validators.validatePassword(password) ??
        Validators.validateKelas(kelas);
    if (validationError != null) {
      return Failure(validationError, code: 'INVALID_INPUT');
    }
    if (_repo.nisExists(nis.trim())) {
      return const Failure(AppStrings.nisAlreadyRegistered, code: 'NIS_EXISTS');
    }

    final newUser = UserModel(
      id: _repo.generateUserId(),
      nis: nis.trim(),
      password: PasswordHasher.hash(password),
      name: name.trim(),
      kelas: kelas.trim(),
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

  Result<UserModel> updateProfilePhoto(
    LocalImage? photo, {
    required String userId,
  }) {
    final user = currentUser;
    if (user == null || user.id != userId) {
      return const Failure(
        'Foto hanya dapat diubah oleh pemilik akun yang sedang masuk.',
      );
    }
    user.profilePhoto = photo;
    notifyListeners();
    return Success(user);
  }

  Result<UserModel> resetStudentPassword(String userId, String newPassword) {
    if (!canManageStudents) {
      return const Failure(
        'Hanya guru aktif yang dapat mereset password.',
        code: 'FORBIDDEN',
      );
    }
    final user = _repo.getUserById(userId);
    if (user == null || user.role != 'Siswa') {
      return const Failure(
        'Akun siswa tidak ditemukan.',
        code: 'STUDENT_NOT_FOUND',
      );
    }
    final error = Validators.validatePassword(newPassword);
    if (newPassword.trim().isEmpty || error != null) {
      return Failure(
        error ?? 'Password tidak boleh hanya berisi spasi.',
        code: 'INVALID_PASSWORD',
      );
    }
    user.password = PasswordHasher.hash(newPassword);
    _recordAccountAction(user, 'Password Direset');
    notifyListeners();
    return Success(user);
  }

  Result<UserModel> setStudentActive(String userId, bool active) {
    if (!canManageStudents) {
      return const Failure(
        'Hanya guru aktif yang dapat mengubah status akun.',
        code: 'FORBIDDEN',
      );
    }
    final user = _repo.getUserById(userId);
    if (user == null || user.role != 'Siswa') {
      return const Failure(
        'Akun siswa tidak ditemukan.',
        code: 'STUDENT_NOT_FOUND',
      );
    }
    if (user.isActive == active) return Success(user);
    user.isActive = active;
    _recordAccountAction(
      user,
      active ? 'Akun Diaktifkan' : 'Akun Dinonaktifkan',
    );
    notifyListeners();
    return Success(user);
  }

  void _recordAccountAction(UserModel student, String title) {
    student.activities.insert(
      0,
      ActivityItem(
        title: title,
        description: 'Oleh guru: ${currentUser!.name}',
        time: DateTime.now(),
        icon: 'account',
      ),
    );
  }

  // ────────────── Authorization Checks ──────────────

  /// Cek apakah user bisa membalas tiket (Guru/Mentor/Moderator)
  bool canReplyToTicket() {
    if (currentUser == null) return false;
    if (_currentUser!.role == 'Guru') return true;
    return _currentUser!.activeRole == UserRole.mentor ||
        _currentUser!.activeRole == UserRole.moderator;
  }

  /// Cek apakah user bisa moderasi tiket (Guru/Moderator)
  bool canModerateTicket() {
    if (currentUser == null) return false;
    if (_currentUser!.role == 'Guru') return true;
    return _currentUser!.activeRole == UserRole.moderator;
  }

  List<BadgeProgress> get achievementProgress {
    final user = currentUser;
    return user == null
        ? []
        : BadgeService.progress(
            user,
            _repo.getAllTickets(),
            _repo.getAllProjects(),
          );
  }

  void _awardBadges(UserModel user) {
    BadgeService.award(user, _repo.getAllTickets(), _repo.getAllProjects());
  }

  // ────────────── User Updates ──────────────
  // Dipanggil oleh provider lain untuk cross-domain updates

  void addPoin(int amount) {
    if (currentUser != null) {
      _currentUser!.poin += amount;
      _awardBadges(_currentUser!);
      notifyListeners();
    }
  }

  void addPoinToUser(String userId, int amount) {
    final user = _repo.getUserById(userId);
    if (user != null) {
      user.poin += amount;
      _awardBadges(user);
      notifyListeners();
    }
  }

  void incrementTicketsCreated() {
    if (currentUser != null) {
      _currentUser!.ticketsCreated += 1;
      notifyListeners();
    }
  }

  void incrementTicketsAnswered() {
    if (currentUser != null) {
      _currentUser!.ticketsAnswered += 1;
      notifyListeners();
    }
  }

  void addActivity(ActivityItem activity) {
    if (currentUser != null) {
      _currentUser!.activities.insert(0, activity);
      notifyListeners();
    }
  }
}
