import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/project_status_badge.dart';
import '../../widgets/local_image_view.dart';
import 'project_revision_screen.dart';
import 'showcase_tab.dart';

class MyProjectsTab extends StatefulWidget {
  const MyProjectsTab({super.key});
  @override
  State<MyProjectsTab> createState() => _MyProjectsTabState();
}

class _MyProjectsTabState extends State<MyProjectsTab> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<ProjectProvider>();
    if (user == null || user.role != 'Siswa') {
      return const Scaffold(
        body: Center(child: Text('Silakan masuk sebagai siswa.')),
      );
    }
    final all = provider.myProjects;
    final projects = all
        .where(
          (project) =>
              _filter == 'Semua' ||
              ProjectStatusBadge.label(project) == _filter,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Karya Saya')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Semua', 'Menunggu Review', 'Disetujui', 'Ditolak']
                    .map(
                      (label) => ChoiceChip(
                        label: Text(label),
                        selected: label == _filter,
                        onSelected: (_) => setState(() => _filter = label),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        all.isEmpty
                            ? 'Belum ada karya. Kirim karya melalui tombol tambah di Showcase.'
                            : 'Tidak ada karya dengan status $_filter.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: projects.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _MyProjectCard(project: projects[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _MyProjectCard({required this.project});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectStatusBadge(project: project),
            if (project.screenshot != null) ...[
              const SizedBox(height: 12),
              LocalImageView(image: project.screenshot),
            ],
            const SizedBox(height: 12),
            Text(project.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(project.category),
            if (project.guruFeedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                !project.isRejected && !project.isValidated
                    ? 'Catatan guru sebelumnya'
                    : 'Catatan guru',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(project.guruFeedback),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ProjectDetailScreen(project: project),
                    ),
                  ),
                  child: const Text('Lihat Detail'),
                ),
                if (project.isRejected && !project.isValidated)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ProjectRevisionScreen(projectId: project.id),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Revisi Karya'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
