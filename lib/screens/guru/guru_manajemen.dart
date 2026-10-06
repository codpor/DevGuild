import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';

class GuruManajemen extends StatefulWidget {
  const GuruManajemen({super.key});
  @override
  State<GuruManajemen> createState() => _GuruManajemenState();
}

class _GuruManajemenState extends State<GuruManajemen>
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
    final authProvider = Provider.of<AuthProvider>(context);
    final roleProvider = Provider.of<RoleProvider>(context);
    final users = authProvider.allUsers;
    final pendingRequests = roleProvider.pendingRoleRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Siswa'),
        bottom: TabBar(
          controller: _tabC,
          tabs: [
            const Tab(text: 'Daftar Siswa'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Permohonan Role'),
                  if (pendingRequests.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${pendingRequests.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabC,
        children: [
          // ── Tab 1: Daftar Siswa
          _SiswaListTab(users: users),
          // ── Tab 2: Permohonan Role
          _RoleRequestsTab(roleProvider: roleProvider),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  TAB 1: DAFTAR SISWA
// ══════════════════════════════════════════════════
class _SiswaListTab extends StatelessWidget {
  final List<UserModel> users;
  const _SiswaListTab({required this.users});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.primary.withValues(alpha: 0.06),
          child: Row(
            children: [
              const Icon(Icons.group, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Total ${users.length} Siswa Terdaftar',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final user = users[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppTheme.primary.withValues(alpha: 0.15),
                        child: Text(user.name[0],
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(
                                'NIS: ${user.nis}  ·  ${user.kelas}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _ActiveRoleChip(user.activeRole),
                                const SizedBox(width: 6),
                                Text('${user.poin} poin',
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: AppTheme.textSecondary),
                        onSelected: (val) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '$val untuk ${user.name}')),
                          );
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'Lihat Detail',
                              child: Text('Lihat Detail')),
                          const PopupMenuItem(
                              value: 'Reset Password',
                              child: Text('Reset Password')),
                          const PopupMenuItem(
                              value: 'Nonaktifkan Akun',
                              child: Text('Nonaktifkan Akun',
                                  style: TextStyle(
                                      color: AppTheme.error))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════
//  TAB 2: PERMOHONAN ROLE
// ══════════════════════════════════════════════════
class _RoleRequestsTab extends StatelessWidget {
  final RoleProvider roleProvider;
  const _RoleRequestsTab({required this.roleProvider});

  @override
  Widget build(BuildContext context) {
    final pending = roleProvider.pendingRoleRequests;
    final history = roleProvider.allRoleRequests
        .where((r) => r.status != RoleRequestStatus.pending)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pending requests
          if (pending.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('Tidak ada permohonan role baru',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15)),
                  ],
                ),
              ),
            ),

          ...pending.map(
              (req) => _RoleRequestCard(request: req, roleProvider: roleProvider)),

          // ── History
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                      color: AppTheme.textSecondary,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                const Text('Riwayat',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),
            ...history.map((req) => _RoleRequestHistoryTile(request: req)),
          ],
        ],
      ),
    );
  }
}

class _RoleRequestCard extends StatelessWidget {
  final RoleRequestModel request;
  final RoleProvider roleProvider;
  const _RoleRequestCard(
      {required this.request, required this.roleProvider});

  @override
  Widget build(BuildContext context) {
    final isMentor = request.requestedRole == UserRole.mentor;
    final roleLabel = isMentor ? 'Mentor' : 'Moderator';
    final roleEmoji = isMentor ? '🎓' : '🛡️';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('⏳ Menunggu Persetujuan',
                      style: TextStyle(
                          color: AppTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(_timeAgo(request.createdAt),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  child: Text(request.userName[0],
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('${request.userKelas} · Ingin menjadi $roleEmoji $roleLabel',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Qualification snapshot
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QualStat(
                      label: 'Poin', value: '${request.userPoin}'),
                  _QualStat(
                      label: 'Karya',
                      value: '${request.userProjectCount}'),
                  _QualStat(
                      label: 'Dijawab',
                      value: '${request.userTicketsAnswered}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showRejectDialog(context, request.id),
                    icon: const Icon(Icons.close,
                        color: AppTheme.error, size: 18),
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
                      roleProvider.approveRoleRequest(request.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${request.userName} disetujui sebagai $roleLabel!'),
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

  void _showRejectDialog(BuildContext context, String requestId) {
    final feedbackC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Permohonan'),
        content: TextField(
          controller: feedbackC,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Alasan Penolakan',
            hintText: 'Berikan feedback untuk siswa...',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              roleProvider.rejectRoleRequest(
                  requestId, feedbackC.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permohonan ditolak'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }
}

class _QualStat extends StatelessWidget {
  final String label, value;
  const _QualStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.primary)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _RoleRequestHistoryTile extends StatelessWidget {
  final RoleRequestModel request;
  const _RoleRequestHistoryTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final isApproved = request.status == RoleRequestStatus.approved;
    final roleLabel =
        request.requestedRole == UserRole.mentor ? 'Mentor' : 'Moderator';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: (isApproved ? AppTheme.success : AppTheme.error)
              .withValues(alpha: 0.12),
          child: Icon(
            isApproved ? Icons.check : Icons.close,
            color: isApproved ? AppTheme.success : AppTheme.error,
            size: 20,
          ),
        ),
        title: Text(request.userName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
            '${isApproved ? "Disetujui" : "Ditolak"} sebagai $roleLabel',
            style: const TextStyle(fontSize: 12)),
        trailing: Text(
          isApproved ? '✅' : '❌',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class _ActiveRoleChip extends StatelessWidget {
  final UserRole role;
  const _ActiveRoleChip(this.role);

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (role) {
      case UserRole.mentor:
        label = '🎓 Mentor';
        color = AppTheme.success;
        break;
      case UserRole.moderator:
        label = '🛡️ Moderator';
        color = AppTheme.warning;
        break;
      case UserRole.mentee:
        label = '🙋 Mentee';
        color = AppTheme.info;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
