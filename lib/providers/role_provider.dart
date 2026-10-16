// lib/providers/role_provider.dart
// Provider khusus manajemen role & permohonan role

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../utils/result.dart';
import 'auth_provider.dart';

class RoleProvider with ChangeNotifier {
  final AppRepository _repo;
  final AuthProvider _authProvider;

  RoleProvider(this._repo, this._authProvider);

  // ────────────── Role Requirements Config ──────────────
  static const int mentorMinPoin = 50;
  static const int mentorMinProjects = 1;
  static const int mentorMinAnswered = 3;

  static const int moderatorMinPoin = 150;
  static const int moderatorMinProjects = 3;
  static const int moderatorMinAnswered = 10;

  // ────────────── Queries ──────────────
  List<RoleRequestModel> get allRoleRequests => _repo.getAllRoleRequests();

  List<RoleRequestModel> get pendingRoleRequests => _repo
      .getAllRoleRequests()
      .where((r) => r.status == RoleRequestStatus.pending)
      .toList();

  // ────────────── Role Switching ──────────────

  /// Mentee: langsung switch tanpa approval
  void switchToMentee() {
    final user = _authProvider.currentUser;
    if (user == null || user.role != 'Siswa') return;
    user.activeRole = UserRole.mentee;
    notifyListeners();
    _authProvider.notifyListeners();
  }

  // ────────────── Requirements Check ──────────────

  Map<String, bool> getMentorRequirements(UserModel user) {
    final projectCount = _repo.getValidatedProjectCount(user.id);
    return {
      'Minimal $mentorMinPoin poin (saat ini: ${user.poin})':
          user.poin >= mentorMinPoin,
      'Minimal $mentorMinProjects karya tervalidasi (saat ini: $projectCount)':
          projectCount >= mentorMinProjects,
      'Minimal $mentorMinAnswered tiket dijawab (saat ini: ${user.ticketsAnswered})':
          user.ticketsAnswered >= mentorMinAnswered,
    };
  }

  Map<String, bool> getModeratorRequirements(UserModel user) {
    final projectCount = _repo.getValidatedProjectCount(user.id);
    return {
      'Minimal $moderatorMinPoin poin (saat ini: ${user.poin})':
          user.poin >= moderatorMinPoin,
      'Minimal $moderatorMinProjects karya tervalidasi (saat ini: $projectCount)':
          projectCount >= moderatorMinProjects,
      'Minimal $moderatorMinAnswered tiket dijawab (saat ini: ${user.ticketsAnswered})':
          user.ticketsAnswered >= moderatorMinAnswered,
    };
  }

  bool canBecomeMentor(UserModel user) =>
      getMentorRequirements(user).values.every((v) => v);

  bool canBecomeModerator(UserModel user) =>
      getModeratorRequirements(user).values.every((v) => v);

  // ────────────── Role Requests ──────────────

  bool hasPendingRoleRequest(String userId) => _repo.getAllRoleRequests().any(
    (r) => r.userId == userId && r.status == RoleRequestStatus.pending,
  );

  RoleRequestModel? getPendingRequest(String userId) => _repo
      .getAllRoleRequests()
      .where((r) => r.userId == userId && r.status == RoleRequestStatus.pending)
      .firstOrNull;

  /// Submit permohonan role (Mentor/Moderator) — perlu approval guru
  Result<RoleRequestModel> submitRoleRequest(UserRole role) {
    final user = _authProvider.currentUser;
    if (user == null || user.role != 'Siswa') {
      return const Failure('Hanya siswa aktif yang dapat mengajukan role.');
    }
    if (role == UserRole.mentee || user.activeRole == role) {
      return const Failure('Pilih role baru Mentor atau Moderator.');
    }
    if (hasPendingRoleRequest(user.id)) {
      return const Failure(
        'Kamu sudah memiliki permohonan yang sedang diproses.',
      );
    }
    if (!_meetsRequirements(user, role)) {
      return const Failure('Persyaratan role belum terpenuhi.');
    }

    final projectCount = _repo.getValidatedProjectCount(user.id);
    final request = RoleRequestModel(
      id: 'rr${DateTime.now().microsecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      userKelas: user.kelas,
      requestedRole: role,
      createdAt: DateTime.now(),
      userPoin: user.poin,
      userProjectCount: projectCount,
      userTicketsAnswered: user.ticketsAnswered,
    );
    _repo.addRoleRequest(request);
    notifyListeners();
    return Success(request);
  }

  bool _meetsRequirements(UserModel user, UserRole role) => switch (role) {
    UserRole.mentor => canBecomeMentor(user),
    UserRole.moderator => canBecomeModerator(user),
    UserRole.mentee => false,
  };

  RoleRequestModel? _pendingRequestById(String requestId) => _repo
      .getAllRoleRequests()
      .where((r) => r.id == requestId && r.status == RoleRequestStatus.pending)
      .firstOrNull;

  Result<RoleRequestModel> approveRoleRequest(String requestId) {
    if (!_authProvider.canManageStudents) {
      return const Failure('Hanya guru aktif yang dapat menyetujui role.');
    }
    final request = _pendingRequestById(requestId);
    if (request == null) {
      return const Failure('Permohonan tidak ditemukan atau sudah diproses.');
    }
    final user = _repo.getUserById(request.userId);
    if (user == null || user.role != 'Siswa' || !user.isActive) {
      return const Failure('Pemohon harus merupakan siswa aktif.');
    }
    if (!_meetsRequirements(user, request.requestedRole)) {
      return const Failure('Persyaratan role siswa sudah tidak terpenuhi.');
    }
    request.status = RoleRequestStatus.approved;
    user.activeRole = request.requestedRole;
    notifyListeners();
    _authProvider.notifyListeners();
    return Success(request);
  }

  Result<RoleRequestModel> rejectRoleRequest(
    String requestId,
    String feedback,
  ) {
    if (!_authProvider.canManageStudents) {
      return const Failure('Hanya guru aktif yang dapat menolak role.');
    }
    final request = _pendingRequestById(requestId);
    if (request == null) {
      return const Failure('Permohonan tidak ditemukan atau sudah diproses.');
    }
    request.status = RoleRequestStatus.rejected;
    request.feedback = feedback.trim();
    notifyListeners();
    return Success(request);
  }
}
