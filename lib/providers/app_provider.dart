// lib/providers/app_provider.dart
// State management terpusat untuk seluruh aplikasi

import 'package:flutter/material.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  // ────────────── CURRENT USER ──────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // ────────────── POIN CONFIG ──────────────
  static const int poinCreateTicket = 5;
  static const int poinReplyTicket = 10;
  static const int poinAcceptedReply = 25;
  static const int poinProjectValidated = 50;
  static const int poinProjectLiked = 2;

  // ────────────── ROLE REQUIREMENTS ──────────────
  static const int mentorMinPoin = 50;
  static const int mentorMinProjects = 1;
  static const int mentorMinAnswered = 3;

  static const int moderatorMinPoin = 150;
  static const int moderatorMinProjects = 3;
  static const int moderatorMinAnswered = 10;

  // ────────────── MOCK USERS ──────────────
  final List<UserModel> _users = [
    UserModel(
      id: 'u1',
      nis: 'admin',
      name: 'Budi Santoso, S.Kom',
      kelas: 'Guru PPLG',
      role: 'Guru',
      poin: 0,
      badges: ['Admin', 'Founder'],
    ),
    UserModel(
      id: 'u2',
      nis: '2201',
      name: 'Arif Fakhry',
      kelas: 'XII PPLG 1',
      role: 'Siswa',
      activeRole: UserRole.mentor,
      poin: 320,
      ticketsCreated: 5,
      ticketsAnswered: 12,
      badges: ['Early Adopter', 'Top Mentor', 'Problem Solver'],
      activities: [
        ActivityItem(
          title: 'Menjawab Tiket',
          description: 'Error koneksi database MySQL',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          icon: 'reply',
        ),
        ActivityItem(
          title: 'Upload Karya',
          description: 'Aplikasi Kasir Sederhana',
          time: DateTime.now().subtract(const Duration(days: 1)),
          icon: 'upload',
        ),
      ],
    ),
    UserModel(
      id: 'u3',
      nis: '2202',
      name: 'Siti Rahayu',
      kelas: 'XI PPLG 2',
      role: 'Siswa',
      activeRole: UserRole.mentee,
      poin: 80,
      ticketsCreated: 8,
      ticketsAnswered: 2,
      badges: ['Curious Coder'],
    ),
    UserModel(
      id: 'u4',
      nis: '2203',
      name: 'Dimas Pratama',
      kelas: 'XII PPLG 2',
      role: 'Siswa',
      activeRole: UserRole.moderator,
      poin: 210,
      ticketsCreated: 3,
      ticketsAnswered: 9,
      badges: ['Moderator', 'Bug Hunter'],
    ),
    UserModel(
      id: 'u5',
      nis: '2204',
      name: 'Nadia Kusuma',
      kelas: 'X PPLG 1',
      role: 'Siswa',
      poin: 45,
      ticketsCreated: 10,
      ticketsAnswered: 1,
      badges: [],
    ),
  ];

  List<UserModel> get allUsers => _users.where((u) => u.role == 'Siswa').toList();

  // ────────────── MOCK TICKETS ──────────────
  final List<TicketModel> _tickets = [
    TicketModel(
      id: 't1',
      authorId: 'u3',
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
          authorId: 'u2',
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
      authorId: 'u5',
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
      authorId: 'u3',
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
          authorId: 'u4',
          authorName: 'Dimas Pratama',
          authorRole: UserRole.moderator,
          content:
              'Coba cek scope variabelnya. Apakah kamu mendefinisikannya di dalam if atau function? Variabel di dalam block tidak bisa diakses di luar.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
    ),
    TicketModel(
      id: 't4',
      authorId: 'u5',
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

  List<TicketModel> get allTickets => List.from(_tickets);
  List<TicketModel> get openTickets =>
      _tickets.where((t) => t.status == TicketStatus.open).toList();
  List<TicketModel> get pendingTickets =>
      _tickets.where((t) => t.status != TicketStatus.solved).toList();

  // ────────────── MOCK PROJECTS ──────────────
  final List<ProjectModel> _projects = [
    ProjectModel(
      id: 'p1',
      authorId: 'u2',
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
      authorId: 'u4',
      authorName: 'Dimas Pratama',
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
      authorId: 'u3',
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
      authorId: 'u5',
      authorName: 'Nadia Kusuma',
      authorKelas: 'X PPLG 1',
      title: 'Kalkulator Sederhana',
      description: 'Kalkulator web dengan tampilan modern menggunakan HTML, CSS, dan JavaScript.',
      category: 'JavaScript',
      linkGithub: 'https://github.com/nadiakusuma/kalkulator',
      teamMembers: ['Nadia Kusuma'],
      teknologi: ['HTML', 'CSS', 'JavaScript'],
      isValidated: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 0,
    ),
  ];

  List<ProjectModel> get allProjects => List.from(_projects);
  List<ProjectModel> get validatedProjects =>
      _projects.where((p) => p.isValidated).toList();
  List<ProjectModel> get pendingProjects =>
      _projects.where((p) => !p.isValidated && !p.isRejected).toList();

  // ────────────── ROLE REQUESTS ──────────────
  final List<RoleRequestModel> _roleRequests = [];
  List<RoleRequestModel> get allRoleRequests => List.from(_roleRequests);
  List<RoleRequestModel> get pendingRoleRequests =>
      _roleRequests.where((r) => r.status == RoleRequestStatus.pending).toList();

  // ────────────── LEADERBOARD ──────────────
  List<UserModel> get leaderboard {
    final siswa = _users.where((u) => u.role == 'Siswa').toList();
    siswa.sort((a, b) => b.poin.compareTo(a.poin));
    return siswa;
  }

  // ────────────── AUTH ──────────────
  bool login(String nis, String password) {
    if (password.isEmpty) return false;
    final user = _users.where((u) => u.nis == nis).firstOrNull;
    if (user == null) return false;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  bool register({
    required String nis,
    required String name,
    required String kelas,
    required String password,
  }) {
    if (_users.any((u) => u.nis == nis)) return false;
    final newUser = UserModel(
      id: 'u${_users.length + 1}',
      nis: nis,
      name: name,
      kelas: kelas,
      role: 'Siswa',
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ────────────── ROLE MANAGEMENT ──────────────
  int getValidatedProjectCount(String userId) {
    return _projects.where((p) => p.authorId == userId && p.isValidated).length;
  }

  Map<String, bool> getMentorRequirements(UserModel user) {
    final projectCount = getValidatedProjectCount(user.id);
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
    final projectCount = getValidatedProjectCount(user.id);
    return {
      'Minimal $moderatorMinPoin poin (saat ini: ${user.poin})':
          user.poin >= moderatorMinPoin,
      'Minimal $moderatorMinProjects karya tervalidasi (saat ini: $projectCount)':
          projectCount >= moderatorMinProjects,
      'Minimal $moderatorMinAnswered tiket dijawab (saat ini: ${user.ticketsAnswered})':
          user.ticketsAnswered >= moderatorMinAnswered,
    };
  }

  bool canBecomeMentor(UserModel user) {
    return getMentorRequirements(user).values.every((v) => v);
  }

  bool canBecomeModerator(UserModel user) {
    return getModeratorRequirements(user).values.every((v) => v);
  }

  bool hasPendingRoleRequest(String userId) {
    return _roleRequests.any(
        (r) => r.userId == userId && r.status == RoleRequestStatus.pending);
  }

  RoleRequestModel? getPendingRequest(String userId) {
    return _roleRequests
        .where((r) =>
            r.userId == userId && r.status == RoleRequestStatus.pending)
        .firstOrNull;
  }

  // Mentee: langsung switch tanpa approval
  void switchToMentee() {
    if (_currentUser == null) return;
    _currentUser!.activeRole = UserRole.mentee;
    notifyListeners();
  }

  // Mentor/Moderator: submit request yang perlu di-approve guru
  void submitRoleRequest(UserRole role) {
    if (_currentUser == null) return;
    if (hasPendingRoleRequest(_currentUser!.id)) return;

    final projectCount = getValidatedProjectCount(_currentUser!.id);
    _roleRequests.add(RoleRequestModel(
      id: 'rr${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      userKelas: _currentUser!.kelas,
      requestedRole: role,
      createdAt: DateTime.now(),
      userPoin: _currentUser!.poin,
      userProjectCount: projectCount,
      userTicketsAnswered: _currentUser!.ticketsAnswered,
    ));
    notifyListeners();
  }

  void approveRoleRequest(String requestId) {
    final request = _roleRequests.firstWhere((r) => r.id == requestId);
    request.status = RoleRequestStatus.approved;
    final user = _users.firstWhere((u) => u.id == request.userId);
    user.activeRole = request.requestedRole;
    notifyListeners();
  }

  void rejectRoleRequest(String requestId, String feedback) {
    final request = _roleRequests.firstWhere((r) => r.id == requestId);
    request.status = RoleRequestStatus.rejected;
    request.feedback = feedback;
    notifyListeners();
  }

  // ────────────── TICKET ACTIONS ──────────────
  void addTicket(TicketModel ticket) {
    _tickets.insert(0, ticket);
    if (_currentUser != null) {
      _currentUser!.poin += poinCreateTicket;
      _currentUser!.ticketsCreated += 1;
      _currentUser!.activities.insert(
          0,
          ActivityItem(
            title: 'Membuat Tiket',
            description: ticket.title,
            time: DateTime.now(),
            icon: 'ticket',
          ));
    }
    notifyListeners();
  }

  bool canReplyToTicket() {
    if (_currentUser == null) return false;
    if (_currentUser!.role == 'Guru') return true;
    return _currentUser!.activeRole == UserRole.mentor;
  }

  void addReply(String ticketId, ReplyModel reply) {
    final ticket = _tickets.firstWhere((t) => t.id == ticketId);
    ticket.replies.add(reply);
    if (ticket.status == TicketStatus.open) {
      ticket.status = TicketStatus.inProgress;
    }
    if (_currentUser != null) {
      _currentUser!.poin += poinReplyTicket;
      _currentUser!.ticketsAnswered += 1;
      _currentUser!.activities.insert(
          0,
          ActivityItem(
            title: 'Menjawab Tiket',
            description: ticket.title,
            time: DateTime.now(),
            icon: 'reply',
          ));
    }
    notifyListeners();
  }

  void markSolved(String ticketId, String replyId) {
    final ticket = _tickets.firstWhere((t) => t.id == ticketId);
    ticket.status = TicketStatus.solved;
    final reply = ticket.replies.firstWhere((r) => r.id == replyId);
    reply.isAccepted = true;
    // Bonus poin untuk yang menjawab
    final author = _users.where((u) => u.id == reply.authorId).firstOrNull;
    if (author != null) {
      author.poin += poinAcceptedReply;
    }
    notifyListeners();
  }

  // ────────────── PROJECT ACTIONS ──────────────
  void addProject(ProjectModel project) {
    _projects.insert(0, project);
    if (_currentUser != null) {
      _currentUser!.activities.insert(
          0,
          ActivityItem(
            title: 'Upload Karya',
            description: project.title,
            time: DateTime.now(),
            icon: 'upload',
          ));
    }
    notifyListeners();
  }

  void validateProject(String projectId, bool approved, {String feedback = ''}) {
    final project = _projects.firstWhere((p) => p.id == projectId);
    if (approved) {
      project.isValidated = true;
      project.guruFeedback = feedback;
      // Poin untuk author
      final author =
          _users.where((u) => u.id == project.authorId).firstOrNull;
      if (author != null) {
        author.poin += poinProjectValidated;
      }
    } else {
      project.isRejected = true;
      project.guruFeedback = feedback;
    }
    notifyListeners();
  }

  void toggleLikeProject(String projectId) {
    if (_currentUser == null) return;
    final project = _projects.firstWhere((p) => p.id == projectId);

    if (_currentUser!.likedProjects.contains(projectId)) {
      _currentUser!.likedProjects.remove(projectId);
      project.likes -= 1;
    } else {
      _currentUser!.likedProjects.add(projectId);
      project.likes += 1;
      // Poin untuk author (hanya saat like, bukan unlike)
      final author =
          _users.where((u) => u.id == project.authorId).firstOrNull;
      if (author != null && author.id != _currentUser!.id) {
        author.poin += poinProjectLiked;
      }
    }
    notifyListeners();
  }

  bool hasLikedProject(String projectId) {
    if (_currentUser == null) return false;
    return _currentUser!.likedProjects.contains(projectId);
  }
}
