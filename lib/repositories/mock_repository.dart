// lib/repositories/mock_repository.dart
// Implementasi in-memory dari AppRepository
// Menggunakan data mock yang sama seperti sebelumnya

import '../models/models.dart';
import '../data/mock_users.dart';
import 'app_repository.dart';

class MockRepository extends AppRepository {
  final List<UserModel> _users = List.from(mockUsers);

  final List<TicketModel> _tickets = [
    TicketModel(
      id: 't1',
      authorId: 'u4',
      authorName: 'Siti Rahayu',
      authorKelas: 'XI PPLG 2',
      title: 'Error koneksi database MySQL di PHP',
      description:
          'Saya sudah mencoba mengikuti tutorial tapi muncul error "Connection Refused". Saya menggunakan XAMPP dan sudah memastikan Apache & MySQL aktif.',
      errorCode: 'SQLSTATE[HY000] [2002] Connection refused',
      category: 'PHP & MySQL',
      status: TicketStatus.solved,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      replies: [
        ReplyModel(
          id: 'r1',
          authorId: 'u3',
          authorName: 'Arif Fakhry',
          authorRole: UserRole.mentor,
          content:
              'Coba cek port MySQL-nya. Biasanya default 3306, tapi di beberapa konfigurasi XAMPP bisa berubah. Pastikan di file php.ini juga sudah benar.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isAccepted: true,
        ),
      ],
    ),
    TicketModel(
      id: 't2',
      authorId: 'u6',
      authorName: 'Nadia Kusuma',
      authorKelas: 'X PPLG 1',
      title: 'Tampilan website tidak rapi di mobile',
      description:
          'Website yang saya buat menggunakan Bootstrap terlihat berantakan saat dibuka di HP. Padding dan margin-nya tidak sesuai.',
      errorCode: '',
      category: 'HTML & CSS',
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      replies: [],
    ),
    TicketModel(
      id: 't3',
      authorId: 'u4',
      authorName: 'Siti Rahayu',
      authorKelas: 'XI PPLG 2',
      title: 'Undefined variable di PHP',
      description:
          'Muncul notice "Undefined variable: nama" padahal sudah saya deklarasikan di atas.',
      errorCode: 'Notice: Undefined variable: nama on line 14',
      category: 'PHP & MySQL',
      status: TicketStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      replies: [
        ReplyModel(
          id: 'r2',
          authorId: 'u5',
          authorName: 'Akun Moderator Demo',
          authorRole: UserRole.moderator,
          content:
              'Coba cek scope variabelnya. Apakah kamu mendefinisikannya di dalam if atau function? Variabel di dalam block tidak bisa diakses di luar.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
    ),
    TicketModel(
      id: 't4',
      authorId: 'u6',
      authorName: 'Nadia Kusuma',
      authorKelas: 'X PPLG 1',
      title: 'Cara membuat form login yang aman',
      description:
          'Saya ingin membuat form login untuk tugas prakerin, bagaimana cara membuat yang aman dari SQL Injection?',
      errorCode: '',
      category: 'Keamanan Web',
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      replies: [],
    ),
  ];

  final List<ProjectModel> _projects = [
    ProjectModel(
      id: 'p1',
      authorId: 'u3',
      authorName: 'Arif Fakhry',
      authorKelas: 'XII PPLG 1',
      title: 'Aplikasi Kasir Sederhana',
      description:
          'Aplikasi kasir berbasis web dengan fitur CRUD produk, transaksi, dan laporan penjualan menggunakan PHP & MySQL.',
      category: 'Web App',
      linkAkses: 'https://kasir-demo.vercel.app',
      linkGithub: 'https://github.com/ariffakhry/kasir-app',
      teamMembers: ['Arif Fakhry', 'Budi Setiawan'],
      teknologi: ['PHP', 'MySQL', 'Bootstrap'],
      isValidated: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likes: 24,
    ),
    ProjectModel(
      id: 'p2',
      authorId: 'u5',
      authorName: 'Akun Moderator Demo',
      authorKelas: 'XII PPLG 2',
      title: 'Sistem Absensi QR Code',
      description:
          'Aplikasi absensi menggunakan QR Code berbasis Python dan Flask dengan database SQLite.',
      category: 'Python',
      linkAkses: 'https://absensi-qr.herokuapp.com',
      linkGithub: 'https://github.com/dimaspratama/absensi-qr',
      teamMembers: ['Dimas Pratama', 'Rizky Aditya'],
      teknologi: ['Python', 'Flask', 'SQLite', 'QR Code'],
      isValidated: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likes: 31,
    ),
    ProjectModel(
      id: 'p3',
      authorId: 'u4',
      authorName: 'Siti Rahayu',
      authorKelas: 'XI PPLG 2',
      title: 'Website Portofolio Personal',
      description:
          'Website portofolio menggunakan HTML, CSS, dan JavaScript dengan animasi scroll yang smooth.',
      category: 'Web',
      linkAkses: 'https://sitirahayu.github.io',
      linkGithub: 'https://github.com/sitirahayu/portfolio',
      teamMembers: ['Siti Rahayu'],
      teknologi: ['HTML', 'CSS', 'JavaScript'],
      isValidated: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likes: 0,
    ),
    ProjectModel(
      id: 'p4',
      authorId: 'u6',
      authorName: 'Nadia Kusuma',
      authorKelas: 'X PPLG 1',
      title: 'Kalkulator Sederhana',
      description:
          'Kalkulator web dengan tampilan modern menggunakan HTML, CSS, dan JavaScript.',
      category: 'JavaScript',
      linkGithub: 'https://github.com/nadiakusuma/kalkulator',
      teamMembers: ['Nadia Kusuma'],
      teknologi: ['HTML', 'CSS', 'JavaScript'],
      isValidated: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 0,
    ),
  ];

  final List<RoleRequestModel> _roleRequests = [];

  // ────────────── Users ──────────────

  @override
  List<UserModel> getAllSiswa() =>
      _users.where((u) => u.role == 'Siswa').toList();

  @override
  UserModel? getUserByNis(String nis) =>
      _users.where((u) => u.nis == nis).firstOrNull;

  @override
  UserModel? getUserById(String id) =>
      _users.where((u) => u.id == id).firstOrNull;

  @override
  void addUser(UserModel user) => _users.add(user);

  @override
  bool nisExists(String nis) => _users.any((u) => u.nis == nis);

  /// Jumlah total user (untuk generate ID baru)
  int get userCount => _users.length;

  // ────────────── Tickets ──────────────

  @override
  List<TicketModel> getAllTickets() => List.from(_tickets);

  @override
  TicketModel getTicketById(String ticketId) =>
      _tickets.firstWhere((t) => t.id == ticketId);

  @override
  void addTicket(TicketModel ticket) => _tickets.insert(0, ticket);

  // ────────────── Projects ──────────────

  @override
  List<ProjectModel> getAllProjects() => List.from(_projects);

  @override
  ProjectModel getProjectById(String projectId) =>
      _projects.firstWhere((p) => p.id == projectId);

  @override
  void addProject(ProjectModel project) => _projects.insert(0, project);

  // ────────────── Role Requests ──────────────

  @override
  List<RoleRequestModel> getAllRoleRequests() => List.from(_roleRequests);

  @override
  RoleRequestModel getRoleRequestById(String requestId) =>
      _roleRequests.firstWhere((r) => r.id == requestId);

  @override
  void addRoleRequest(RoleRequestModel request) =>
      _roleRequests.add(request);

  // ────────────── Leaderboard ──────────────

  @override
  List<UserModel> getLeaderboard() {
    final siswa = _users.where((u) => u.role == 'Siswa').toList();
    siswa.sort((a, b) => b.poin.compareTo(a.poin));
    return siswa;
  }

  // ────────────── Computed Queries ──────────────

  @override
  int getValidatedProjectCount(String userId) =>
      _projects.where((p) => p.authorId == userId && p.isValidated).length;
}
