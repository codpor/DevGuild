import 'models.dart';

/// Semua data domain yang harus disimpan bersama dalam satu transaksi.
class AppState {
  final List<UserModel> users;
  final List<TicketModel> tickets;
  final List<ProjectModel> projects;
  final List<RoleRequestModel> roleRequests;

  AppState({
    required List<UserModel> users,
    required List<TicketModel> tickets,
    required List<ProjectModel> projects,
    List<RoleRequestModel> roleRequests = const [],
  }) : users = List.of(users),
       tickets = List.of(tickets),
       projects = List.of(projects),
       roleRequests = List.of(roleRequests);
}
