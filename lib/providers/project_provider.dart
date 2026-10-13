// lib/providers/project_provider.dart
// Provider khusus manajemen proyek/karya

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../constants/app_strings.dart';
import '../utils/result.dart';
import '../utils/validators.dart';
import 'auth_provider.dart';

class ProjectProvider with ChangeNotifier {
  final AppRepository _repo;
  final AuthProvider _authProvider;

  ProjectProvider(this._repo, this._authProvider);

  // ────────────── Poin Config ──────────────
  static const int poinProjectValidated = 50;
  static const int poinProjectLiked = 2;

  // ────────────── Queries ──────────────
  List<ProjectModel> get allProjects => _repo.getAllProjects();

  List<ProjectModel> get myProjects {
    final user = _authProvider.currentUser;
    if (user == null || user.role != 'Siswa') return [];
    final projects = _repo
        .getAllProjects()
        .where((project) => project.authorId == user.id)
        .toList();
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  /// Memperbarui karya ditolak tanpa mengubah kepemilikan, ID, atau poin.
  Result<ProjectModel> resubmitProject({
    required String projectId,
    required String title,
    required String description,
    required String category,
    required String linkAkses,
    required String linkGithub,
    required List<String> teamMembers,
    required List<String> teknologi,
  }) {
    final user = _authProvider.currentUser;
    if (user == null || user.role != 'Siswa') {
      return const Failure('Silakan masuk sebagai siswa terlebih dahulu.');
    }
    final project = _repo
        .getAllProjects()
        .where((project) => project.id == projectId)
        .firstOrNull;
    if (project == null) return const Failure('Karya tidak ditemukan.');
    if (project.authorId != user.id) {
      return const Failure('Kamu hanya dapat merevisi karya milik sendiri.');
    }
    if (!project.isRejected || project.isValidated) {
      return const Failure('Hanya karya yang ditolak yang dapat direvisi.');
    }
    final validationError =
        Validators.validateRequired(title, 'Nama karya') ??
        Validators.validateRequired(description, 'Deskripsi') ??
        (AppStrings.projectCategories.contains(category)
            ? null
            : 'Pilih kategori karya yang valid.') ??
        Validators.validateOptionalUrl(linkAkses) ??
        Validators.validateOptionalUrl(linkGithub);
    if (validationError != null) return Failure(validationError);
    List<String> clean(List<String> values) => values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final members = clean(teamMembers);
    project.title = title.trim();
    project.description = description.trim();
    project.category = category;
    project.linkAkses = linkAkses.trim();
    project.linkGithub = linkGithub.trim();
    project.teamMembers = members.isEmpty ? [user.name] : members;
    project.teknologi = clean(teknologi);
    project.isValidated = false;
    project.isRejected = false;
    // Catatan terakhir tetap tersedia sampai guru meninjau ulang.
    _authProvider.addActivity(
      ActivityItem(
        title: 'Mengirim Revisi Karya',
        description: project.title,
        time: DateTime.now(),
        icon: 'upload',
      ),
    );
    notifyListeners();
    return Success(project);
  }

  List<ProjectModel> get validatedProjects =>
      _repo.getAllProjects().where((p) => p.isValidated).toList();

  List<ProjectModel> get pendingProjects => _repo
      .getAllProjects()
      .where((p) => !p.isValidated && !p.isRejected)
      .toList();

  // ────────────── Actions ──────────────

  void addProject(ProjectModel project) {
    _repo.addProject(project);

    _authProvider.addActivity(
      ActivityItem(
        title: AppStrings.activityUploadProject,
        description: project.title,
        time: DateTime.now(),
        icon: 'upload',
      ),
    );

    notifyListeners();
  }

  void validateProject(
    String projectId,
    bool approved, {
    String feedback = '',
  }) {
    if (_authProvider.currentUser?.role != 'Guru') return;
    final project = _repo.getProjectById(projectId);
    // Hanya karya pending yang boleh ditinjau; keputusan ulang tidak memberi poin.
    if (project.isValidated || project.isRejected) return;
    project.isValidated = approved;
    project.isRejected = !approved;
    project.guruFeedback = feedback.trim();
    if (approved) {
      _authProvider.addPoinToUser(project.authorId, poinProjectValidated);
    }
    notifyListeners();
  }

  void toggleLikeProject(String projectId) {
    final user = _authProvider.currentUser;
    if (user == null) return;

    final project = _repo.getProjectById(projectId);

    if (!project.isValidated || project.isRejected) return;

    if (user.likedProjects.contains(projectId)) {
      user.likedProjects.remove(projectId);
      project.likes -= 1;
      // Poin mengikuti like aktif, sehingga unlike/like tidak menggandakan poin.
      if (project.authorId != user.id) {
        _authProvider.addPoinToUser(project.authorId, -poinProjectLiked);
      }
    } else {
      user.likedProjects.add(projectId);
      project.likes += 1;
      // Like karya sendiri tidak menghasilkan poin.
      if (project.authorId != user.id) {
        _authProvider.addPoinToUser(project.authorId, poinProjectLiked);
      }
    }
    notifyListeners();
  }

  bool hasLikedProject(String projectId) {
    final user = _authProvider.currentUser;
    if (user == null) return false;
    return user.likedProjects.contains(projectId);
  }
}
