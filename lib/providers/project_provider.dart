// lib/providers/project_provider.dart
// Provider khusus manajemen proyek/karya

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../constants/app_strings.dart';
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

  List<ProjectModel> get validatedProjects =>
      _repo.getAllProjects().where((p) => p.isValidated).toList();

  List<ProjectModel> get pendingProjects =>
      _repo
          .getAllProjects()
          .where((p) => !p.isValidated && !p.isRejected)
          .toList();

  // ────────────── Actions ──────────────

  void addProject(ProjectModel project) {
    _repo.addProject(project);

    _authProvider.addActivity(ActivityItem(
      title: AppStrings.activityUploadProject,
      description: project.title,
      time: DateTime.now(),
      icon: 'upload',
    ));

    notifyListeners();
  }

  void validateProject(String projectId, bool approved,
      {String feedback = ''}) {
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
