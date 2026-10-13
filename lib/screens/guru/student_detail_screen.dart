import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/project_status_badge.dart';
import '../siswa/clinic_tab.dart';
import '../siswa/showcase_tab.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.currentUser?.role != 'Guru') {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Siswa')),
        body: const Center(
          child: Text('Detail siswa hanya dapat diakses guru.'),
        ),
      );
    }
    final student = auth.allUsers
        .where((user) => user.id == studentId)
        .firstOrNull;
    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Siswa')),
        body: const Center(child: Text('Siswa tidak ditemukan.')),
      );
    }
    final projects =
        context
            .watch<ProjectProvider>()
            .allProjects
            .where((project) => project.authorId == student.id)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final tickets =
        context
            .watch<TicketProvider>()
            .allTickets
            .where((ticket) => ticket.authorId == student.id)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final activities = [...student.activities]
      ..sort((a, b) => b.time.compareTo(a.time));
    final role = student.activeRole.name;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Siswa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (student.profilePhoto != null) ...[
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: MemoryImage(student.profilePhoto!.bytes),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(student.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('NIS: ${student.nis}'),
          Text('Kelas: ${student.kelas}'),
          Text('Peran aktif: ${role[0].toUpperCase()}${role.substring(1)}'),
          const SizedBox(height: 20),
          const _SectionTitle('Statistik Kontribusi'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${student.poin} poin')),
              Chip(label: Text('${student.ticketsCreated} tiket dibuat')),
              Chip(label: Text('${student.ticketsAnswered} tiket dijawab')),
              Chip(label: Text('${projects.length} karya')),
              Chip(
                label: Text(
                  '${projects.where((p) => p.isValidated && !p.isRejected).length} karya disetujui',
                ),
              ),
              Chip(
                label: Text(
                  '${projects.where((p) => !p.isValidated && !p.isRejected).length} karya menunggu review',
                ),
              ),
              Chip(
                label: Text(
                  '${projects.where((p) => p.isRejected).length} karya ditolak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Badge & Pencapaian'),
          if (student.badges.isEmpty)
            const Text('Belum ada badge')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: student.badges
                  .map((badge) => Chip(label: Text(badge)))
                  .toList(),
            ),
          const SizedBox(height: 20),
          const _SectionTitle('Daftar Karya'),
          if (projects.isEmpty) const Text('Belum ada karya'),
          ...projects.map(
            (project) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectStatusBadge(project: project),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(project.title),
                      subtitle: Text(project.category),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ProjectDetailScreen(project: project),
                        ),
                      ),
                    ),
                    if (project.guruFeedback.isNotEmpty)
                      Text('Catatan guru: ${project.guruFeedback}'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Tiket Siswa'),
          if (tickets.isEmpty) const Text('Belum ada tiket'),
          ...tickets.map(
            (ticket) => Card(
              child: ListTile(
                title: Text(ticket.title),
                subtitle: Text(
                  '${ticket.category} • ${ticket.replies.length} balasan',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => TicketDetailScreen(ticket: ticket),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Aktivitas Terbaru'),
          if (activities.isEmpty) const Text('Belum ada aktivitas'),
          ...activities
              .take(10)
              .map(
                (activity) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(activity.title),
                  subtitle: Text(activity.description),
                ),
              ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
