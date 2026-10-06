// lib/repositories/app_repository.dart
// Abstract repository interface — kontrak data layer
// Saat ini diimplementasikan oleh MockRepository (in-memory).
// Nantinya bisa di-swap ke FirebaseRepository, ApiRepository, dll.

import '../models/models.dart';

abstract class AppRepository {
  // ────────────── Users ──────────────
  List<UserModel> getAllSiswa();
  UserModel? getUserByNis(String nis);
  UserModel? getUserById(String id);
  void addUser(UserModel user);
  bool nisExists(String nis);

  // ────────────── Tickets ──────────────
  List<TicketModel> getAllTickets();
  TicketModel getTicketById(String ticketId);
  void addTicket(TicketModel ticket);

  // ────────────── Projects ──────────────
  List<ProjectModel> getAllProjects();
  ProjectModel getProjectById(String projectId);
  void addProject(ProjectModel project);

  // ────────────── Role Requests ──────────────
  List<RoleRequestModel> getAllRoleRequests();
  RoleRequestModel getRoleRequestById(String requestId);
  void addRoleRequest(RoleRequestModel request);

  // ────────────── Leaderboard ──────────────
  List<UserModel> getLeaderboard();

  // ────────────── Computed Queries ──────────────
  int getValidatedProjectCount(String userId);
}
