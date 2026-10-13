import '../models/models.dart';

class BadgeProgress {
  final String name;
  final String description;
  final int current;
  final int target;
  final bool earned;
  const BadgeProgress({
    required this.name,
    required this.description,
    required this.current,
    required this.target,
    required this.earned,
  });
  bool get eligible => current >= target;
}

class BadgeService {
  static List<BadgeProgress> progress(
    UserModel user,
    List<TicketModel> tickets,
    List<ProjectModel> projects,
  ) {
    if (user.role != 'Siswa') return [];
    final created = tickets.where((t) => t.authorId == user.id).length;
    final answered = tickets
        .where(
          (t) =>
              t.authorId != user.id &&
              t.replies.any((r) => r.authorId == user.id),
        )
        .length;
    final solved = tickets
        .where(
          (t) =>
              t.authorId != user.id &&
              t.status == TicketStatus.solved &&
              t.replies.any((r) => r.authorId == user.id && r.isAccepted),
        )
        .length;
    final validated = projects
        .where((p) => p.authorId == user.id && p.isValidated && !p.isRejected)
        .length;
    BadgeProgress badge(
      String name,
      String description,
      int current,
      int target,
    ) => BadgeProgress(
      name: name,
      description: description,
      current: current,
      target: target,
      earned: user.badges.contains(name),
    );
    return [
      badge('Penanya Aktif', 'Buat 3 tiket di Klinik Kode.', created, 3),
      badge(
        'Rekan Belajar',
        'Jawab 3 tiket berbeda milik siswa lain.',
        answered,
        3,
      ),
      badge(
        'Pemecah Masalah',
        'Dapatkan 1 jawaban terbaik pada tiket siswa lain.',
        solved,
        1,
      ),
      badge(
        'Kreator',
        'Dapatkan persetujuan guru untuk 1 karya.',
        validated,
        1,
      ),
      badge(
        'Kreator Produktif',
        'Dapatkan persetujuan guru untuk 3 karya.',
        validated,
        3,
      ),
    ];
  }

  static List<String> award(
    UserModel user,
    List<TicketModel> tickets,
    List<ProjectModel> projects,
  ) {
    final awarded = <String>[];
    for (final badge in progress(user, tickets, projects)) {
      if (badge.eligible && !badge.earned) {
        user.badges.add(badge.name);
        user.activities.insert(
          0,
          ActivityItem(
            title: 'Mendapat Badge',
            description: badge.name,
            time: DateTime.now(),
            icon: 'badge',
          ),
        );
        awarded.add(badge.name);
      }
    }
    return awarded;
  }
}
