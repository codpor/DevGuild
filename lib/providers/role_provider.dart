// lib/providers/role_provider.dart
// Provider khusus manajemen role & permohonan role

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
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
    if (user == null) return;
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

  bool hasPendingRoleRequest(String userId) => _repo
      .getAllRoleRequests()
      .any((r) => r.userId == userId && r.status == RoleRequestStatus.pending);

  RoleRequestModel? getPendingRequest(String userId) => _repo
      .getAllRoleRequests()
      .where(
          (r) => r.userId == userId && r.status == RoleRequestStatus.pending)
      .firstOrNull;

  /// Submit permohonan role (Mentor/Moderator) — perlu approval guru
  void submitRoleRequest(UserRole role) {
    final user = _authProvider.currentUser;
    if (user == null) return;
    if (hasPendingRoleRequest(user.id)) return;

    final projectCount = _repo.getValidatedProjectCount(user.id);
    _repo.addRoleRequest(RoleRequestModel(
      id: 'rr${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      userKelas: user.kelas,
      requestedRole: role,
      createdAt: DateTime.now(),
      userPoin: user.poin,
      userProjectCount: projectCount,
      userTicketsAnswered: user.ticketsAnswered,
    ));
    notifyListeners();
  }

  void approveRoleRequest(String requestId) {
    final request = _repo.getRoleRequestById(requestId);
    request.status = RoleRequestStatus.approved;
    final user = _repo.getUserById(request.userId);
    if (user != null) {
      user.activeRole = request.requestedRole;
    }
    notifyListeners();
    _authProvider.notifyListeners();
  }

  void rejectRoleRequest(String requestId, String feedback) {
    final request = _repo.getRoleRequestById(requestId);
    request.status = RoleRequestStatus.rejected;
    request.feedback = feedback;
    notifyListeners();
  }
}
