import '../models/app_state.dart';
import '../models/models.dart';
import 'app_repository.dart';

/// Queries sinkron untuk data yang sudah dimuat saat aplikasi dibuka.
class MemoryRepository extends AppRepository {
  final AppState state;
  int _nextUserId = 1;

  MemoryRepository(this.state);

  @override
  List<UserModel> getAllSiswa() =>
      state.users.where((user) => user.role == 'Siswa').toList();
  @override
  UserModel? getUserByNis(String nis) =>
      state.users.where((user) => user.nis == nis).firstOrNull;
  @override
  UserModel? getUserById(String id) =>
      state.users.where((user) => user.id == id).firstOrNull;
  @override
  void addUser(UserModel user) => state.users.add(user);
  @override
  bool nisExists(String nis) => state.users.any((user) => user.nis == nis);
  @override
  String generateUserId() {
    String id;
    do {
      id = 'u${_nextUserId++}';
    } while (getUserById(id) != null);
    return id;
  }

  @override
  List<TicketModel> getAllTickets() => List.of(state.tickets);
  @override
  TicketModel? getTicketById(String id) =>
      state.tickets.where((ticket) => ticket.id == id).firstOrNull;
  @override
  void addTicket(TicketModel ticket) => state.tickets.insert(0, ticket);

  @override
  List<ProjectModel> getAllProjects() => List.of(state.projects);
  @override
  ProjectModel? getProjectById(String id) =>
      state.projects.where((project) => project.id == id).firstOrNull;
  @override
  void addProject(ProjectModel project) => state.projects.insert(0, project);

  @override
  List<RoleRequestModel> getAllRoleRequests() => List.of(state.roleRequests);
  @override
  RoleRequestModel? getRoleRequestById(String id) =>
      state.roleRequests.where((request) => request.id == id).firstOrNull;
  @override
  void addRoleRequest(RoleRequestModel request) =>
      state.roleRequests.add(request);

  @override
  List<UserModel> getLeaderboard() =>
      getAllSiswa()..sort((a, b) => b.poin.compareTo(a.poin));
  @override
  int getValidatedProjectCount(String userId) => state.projects
      .where((project) => project.authorId == userId && project.isValidated)
      .length;
}
