import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/role_provider.dart';
import '../../router/app_router.dart';
import '../../theme.dart';

class GuruDashboard extends StatelessWidget {
  const GuruDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final roleProvider = Provider.of<RoleProvider>(context);
    
    final user = authProvider.currentUser!;
    final totalSiswa = authProvider.allUsers.length;
    final openTickets = ticketProvider.openTickets.length;
    final pendingKarya = projectProvider.pendingProjects.length;
    final totalKarya = projectProvider.allProjects.length;

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
            onPressed: () => _showLogoutDialog(context, authProvider),
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
                          value: '${authProvider.leaderboard.isNotEmpty ? authProvider.leaderboard.first.poin : 0}',
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
                  onTap: () => _navigateToTab(context, 2),
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  icon: Icons.bug_report_outlined,
                  title: 'Tiket Terbuka',
                  count: openTickets,
                  color: AppTheme.error,
                  desc: 'Belum ada jawaban',
                  onTap: () => _navigateToTab(context, 3),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Permohonan Role',
                  count: roleProvider.pendingRoleRequests.length,
                  color: AppTheme.info,
                  desc: 'Menunggu persetujuan',
                  onTap: () => _navigateToTab(context, 1),
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
            ...authProvider.leaderboard
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

  void _navigateToTab(BuildContext context, int tabIndex) {
    // Find the parent GuruHome state and switch tab
    final scaffoldState = context.findAncestorStateOfType<State>();
    if (scaffoldState != null && scaffoldState.mounted) {
      // Use a callback to update the parent's tab index
      try {
        // ignore: avoid_dynamic_calls
        (scaffoldState as dynamic).setState(() {
          (scaffoldState as dynamic)._currentIndex = tabIndex;
        });
        } catch (_) {
          // Fallback: show a snackbar guiding the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Navigasi ke tab ${['Dashboard', 'Siswa', 'Validasi', 'Monitoring', 'Klinik'][tabIndex]}'),
              backgroundColor: AppTheme.primary,
            ),
          );
      }
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.error),
            SizedBox(width: 10),
            Text('Keluar'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.logout();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Ya, Keluar'),
          ),
        ],
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
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.desc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }
}
