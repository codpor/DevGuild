import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/ticket_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    context.watch<TicketProvider>();
    context.watch<ProjectProvider>();
    final user = auth.currentUser;
    if (user == null || user.role != 'Siswa') {
      return Scaffold(
        appBar: AppBar(title: const Text('Pencapaian')),
        body: const Center(child: Text('Silakan masuk sebagai siswa.')),
      );
    }
    final progress = auth.achievementProgress;
    return Scaffold(
      appBar: AppBar(title: const Text('Pencapaian')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Badge diberikan otomatis saat syarat terpenuhi. Badge yang sudah diperoleh tetap menjadi pencapaianmu.',
          ),
          const SizedBox(height: 16),
          ...progress.map(
            (badge) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          badge.earned
                              ? Icons.military_tech
                              : Icons.lock_outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            badge.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(badge.description),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (badge.current / badge.target).clamp(0.0, 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge.earned
                          ? 'Sudah diperoleh'
                          : 'Progres: ${badge.current}/${badge.target}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
