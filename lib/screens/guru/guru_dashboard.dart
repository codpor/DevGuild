import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';

class GuruDashboard extends StatelessWidget {
  const GuruDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser!;
    final totalSiswa = provider.allUsers.length;
    final openTickets = provider.openTickets.length;
    final pendingKarya = provider.pendingProjects.length;
    final totalKarya = provider.allProjects.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${user.name.split(',').first}! 👋',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Admin Dashboard',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48C6EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Ekosistem',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('SMK PPLG · ${DateTime.now().year}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _BannerStat(value: '$totalSiswa', label: 'Siswa Aktif'),
                      _BannerStat(value: '$totalKarya', label: 'Karya Total'),
                      _BannerStat(
                          value: '${provider.leaderboard.isNotEmpty ? provider.leaderboard.first.poin : 0}',
                          label: 'Poin Tertinggi'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Action cards
            const Text('Perlu Tindakan',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionCard(
                  icon: Icons.pending_actions,
                  title: 'Karya Pending',
                  count: pendingKarya,
                  color: AppTheme.warning,
                  desc: 'Menunggu validasi',
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  icon: Icons.bug_report_outlined,
                  title: 'Tiket Terbuka',
                  count: openTickets,
                  color: AppTheme.error,
                  desc: 'Belum ada jawaban',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Permohonan Role',
                  count: provider.pendingRoleRequests.length,
                  color: AppTheme.info,
                  desc: 'Menunggu persetujuan',
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 20),

            // ── Top Mentor
            const Text('Top Mentor',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...provider.leaderboard
                .take(5)
                .toList()
                .asMap()
                .entries
                .map((e) {
              final rank = e.key + 1;
              final u = e.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank <= 3
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : Colors.grey.shade200,
                    child: Text(['🥇', '🥈', '🥉', '4', '5'][rank - 1],
                        style: const TextStyle(fontSize: 16)),
                  ),
                  title: Text(u.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(u.kelas),
                  trailing: Text('${u.poin} pts',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String value, label;
  const _BannerStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final int count;
  final Color color;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text('$count',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Text(desc,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
