// lib/models/models.dart
// Semua model data untuk DevGuild

enum UserRole { mentee, mentor, moderator }
enum TicketStatus { open, inProgress, solved }
enum RoleRequestStatus { pending, approved, rejected }

class UserModel {
  final String id;
  final String nis;
  final String name;
  final String kelas;
  final String role; // 'Siswa' or 'Guru'
  UserRole activeRole;
  int poin;
  int ticketsCreated;
  int ticketsAnswered;
  final List<String> badges;
  final List<ActivityItem> activities;
  final Set<String> likedProjects;

  UserModel({
    required this.id,
    required this.nis,
    required this.name,
    required this.kelas,
    required this.role,
    this.activeRole = UserRole.mentee,
    this.poin = 0,
    this.ticketsCreated = 0,
    this.ticketsAnswered = 0,
    this.badges = const [],
    List<ActivityItem>? activities,
    Set<String>? likedProjects,
  }) : activities = activities ?? [],
       likedProjects = likedProjects ?? {};
}

class ActivityItem {
  final String title;
  final String description;
  final DateTime time;
  final String icon;

  ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });
}

class TicketModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorKelas;
  final String title;
  final String description;
  final String errorCode;
  final String category;
  TicketStatus status;
  final DateTime createdAt;
  final List<ReplyModel> replies;

  TicketModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorKelas,
    required this.title,
    required this.description,
    this.errorCode = '',
    this.category = 'Umum',
    this.status = TicketStatus.open,
    required this.createdAt,
    List<ReplyModel>? replies,
  }) : replies = replies ?? [];
}

class ReplyModel {
  final String id;
  final String authorId;
  final String authorName;
  final UserRole authorRole;
  final String content;
  final DateTime createdAt;
  bool isAccepted;

  ReplyModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorRole = UserRole.mentee,
    required this.content,
    required this.createdAt,
    this.isAccepted = false,
  });
}

class ProjectModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorKelas;
  final String title;
  final String description;
  final String category;
  final String linkAkses;
  final String linkGithub;
  final List<String> teamMembers;
  final List<String> teknologi;
  bool isValidated;
  bool isRejected;
  String guruFeedback;
  final DateTime createdAt;
  int likes;

  ProjectModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorKelas,
    required this.title,
    required this.description,
    this.category = 'Web',
    this.linkAkses = '',
    this.linkGithub = '',
    this.teamMembers = const [],
    this.teknologi = const [],
    this.isValidated = false,
    this.isRejected = false,
    this.guruFeedback = '',
    required this.createdAt,
    this.likes = 0,
  });
}

class RoleRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userKelas;
  final UserRole requestedRole;
  final DateTime createdAt;
  RoleRequestStatus status;
  String feedback;
  final int userPoin;
  final int userProjectCount;
  final int userTicketsAnswered;

  RoleRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userKelas,
    required this.requestedRole,
    required this.createdAt,
    this.status = RoleRequestStatus.pending,
    this.feedback = '',
    this.userPoin = 0,
    this.userProjectCount = 0,
    this.userTicketsAnswered = 0,
  });
}
