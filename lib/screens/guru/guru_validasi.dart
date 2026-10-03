import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';

class GuruValidasi extends StatefulWidget {
  const GuruValidasi({super.key});
  @override
  State<GuruValidasi> createState() => _GuruValidasiState();
}

class _GuruValidasiState extends State<GuruValidasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabC;

  @override
  void initState() {
    super.initState();
    _tabC = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final pending = provider.pendingProjects;
    final validated = provider.validatedProjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi Karya'),
        bottom: TabBar(
          controller: _tabC,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Disetujui (${validated.length})'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabC,
        children: [
          // ── Pending
          pending.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: AppTheme.success),
                      SizedBox(height: 16),
                      Text('Semua karya sudah divalidasi!',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _PendingProjectCard(project: pending[i]),
                ),

          // ── Validated
          validated.isEmpty
              ? const Center(child: Text('Belum ada karya disetujui'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: validated.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _ValidatedCard(project: validated[i]),
                ),
        ],
      ),
    );
  }
}

class _PendingProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _PendingProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('⏳ Menunggu Review',
                      style: TextStyle(
                          color: AppTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(project.category,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            // Mock thumbnail
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.code,
                    size: 40,
                    color: AppTheme.primary.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text(project.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(project.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text('${project.authorName} · ${project.authorKelas}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showRejectDialog(context, provider, project),
                    icon: const Icon(Icons.close, color: AppTheme.error, size: 18),
                    label: const Text('Tolak',
                        style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.validateProject(project.id, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Karya disetujui & masuk Showcase!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

void _showRejectDialog(
    BuildContext context, AppProvider provider, ProjectModel project) {
  final feedbackC = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tolak Karya'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Karya: ${project.title}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          Text('Oleh: ${project.authorName}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: feedbackC,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alasan Penolakan *',
              hintText: 'Berikan catatan agar siswa bisa memperbaiki...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (feedbackC.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Mohon isi alasan penolakan'),
                    backgroundColor: AppTheme.warning),
              );
              return;
            }
            provider.validateProject(
                project.id, false, feedback: feedbackC.text.trim());
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Karya ditolak dengan catatan'),
                backgroundColor: AppTheme.error,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('Tolak'),
        ),
      ],
    ),
  );
}
}

class _ValidatedCard extends StatelessWidget {
  final ProjectModel project;
  const _ValidatedCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle_outline,
              color: AppTheme.success, size: 26),
        ),
        title: Text(project.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${project.authorName} · ${project.category}',
            style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 14, color: AppTheme.accent),
            Text('${project.likes}',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
