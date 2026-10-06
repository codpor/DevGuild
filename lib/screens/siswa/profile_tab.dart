import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            child: Text(user.name[0],
                                style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: AppTheme.secondary,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(user.kelas,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Role Switcher
                  _RoleSwitcher(currentRole: user.activeRole),
                  const SizedBox(height: 20),

                  // ── Stats
                  Row(
                    children: [
                      _StatCard(
                          icon: Icons.confirmation_number_outlined,
                          value: '${user.ticketsCreated}',
                          label: 'Tiket\nDibuat',
                          color: AppTheme.info),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.chat_bubble_outline,
                          value: '${user.ticketsAnswered}',
                          label: 'Tiket\nDijawab',
                          color: AppTheme.success),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.star_outline,
                          value: '${user.poin}',
                          label: 'Total\nPoin',
                          color: AppTheme.warning),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Badges
                  const Text('Badge & Pencapaian',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  user.badges.isEmpty
                      ? const Text('Belum ada badge',
                          style: TextStyle(color: AppTheme.textSecondary))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.badges
                              .map((b) => _BadgeChip(label: b))
                              .toList(),
                        ),
                  const SizedBox(height: 20),

                  // ── Activity
                  const Text('Aktivitas Terbaru',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  user.activities.isEmpty
                      ? const Text('Belum ada aktivitas',
                          style: TextStyle(color: AppTheme.textSecondary))
                      : Column(
                          children: user.activities
                              .take(5)
                              .map((a) => _ActivityTile(activity: a))
                              .toList(),
                        ),
                  const SizedBox(height: 20),

                  // ── Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, authProvider),
                      icon: const Icon(Icons.logout, color: AppTheme.error),
                      label: const Text('Keluar',
                          style: TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.error)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            provider.logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('Ya, Keluar'),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════
//  ROLE SWITCHER — with requirements & approval flow
// ══════════════════════════════════════════════════════
class _RoleSwitcher extends StatelessWidget {
  final UserRole currentRole;
  const _RoleSwitcher({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final roleProvider = Provider.of<RoleProvider>(context);
    final user = authProvider.currentUser!;
    final pendingRequest = roleProvider.getPendingRequest(user.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mode Aktif Saya',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            const Text(
                'Ganti peran sesuai yang ingin kamu lakukan sekarang.',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            Row(
              children: [
                _RoleButton(
                  label: 'Mentee',
                  icon: '🙋',
                  desc: 'Bertanya',
                  role: UserRole.mentee,
                  current: currentRole,
                  onTap: () => roleProvider.switchToMentee(),
                ),
                const SizedBox(width: 8),
                _RoleButton(
                  label: 'Mentor',
                  icon: '🎓',
                  desc: 'Menjawab',
                  role: UserRole.mentor,
                  current: currentRole,
                  onTap: () => _showRoleRequestDialog(
                      context, UserRole.mentor),
                ),
                const SizedBox(width: 8),
                _RoleButton(
                  label: 'Moderator',
                  icon: '🛡️',
                  desc: 'Mengawasi',
                  role: UserRole.moderator,
                  current: currentRole,
                  onTap: () => _showRoleRequestDialog(
                      context, UserRole.moderator),
                ),
              ],
            ),
            // ── Pending request info
            if (pendingRequest != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top,
                        size: 16, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Permohonan menjadi ${pendingRequest.requestedRole == UserRole.mentor ? "Mentor" : "Moderator"} sedang menunggu persetujuan guru.',
                        style: const TextStyle(
                            color: AppTheme.warning, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRoleRequestDialog(BuildContext context, UserRole role) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    // Jika sudah role tersebut, tidak perlu request
    if (user.activeRole == role) return;

    // Jika sudah ada pending request
    if (roleProvider.hasPendingRoleRequest(user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamu sudah memiliki permohonan yang sedang diproses.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    final isMentor = role == UserRole.mentor;
    final requirements = isMentor
        ? roleProvider.getMentorRequirements(user)
        : roleProvider.getModeratorRequirements(user);
    final canApply =
        isMentor ? roleProvider.canBecomeMentor(user) : roleProvider.canBecomeModerator(user);
    final roleLabel = isMentor ? 'Mentor' : 'Moderator';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  isMentor ? '🎓' : '🛡️',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menjadi $roleLabel',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        isMentor
                            ? 'Bantu teman-temanmu dengan menjawab tiket di Klinik Kode'
                            : 'Jaga komunitas agar tetap kondusif dan produktif',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Requirements checklist
            const Text('Persyaratan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            ...requirements.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        entry.value
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 20,
                        color: entry.value
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: entry.value
                                ? AppTheme.textPrimary
                                : AppTheme.error,
                            fontWeight: entry.value
                                ? FontWeight.normal
                                : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            if (!canApply) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppTheme.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kamu belum memenuhi semua persyaratan. Terus berkontribusi untuk memenuhinya!',
                        style:
                            TextStyle(color: AppTheme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],

            if (canApply) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: AppTheme.success),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Semua persyaratan terpenuhi! Permohonanmu akan dikirim ke guru untuk disetujui.',
                        style: TextStyle(
                            color: AppTheme.success, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  roleProvider.submitRoleRequest(role);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Permohonan menjadi $roleLabel berhasil dikirim! Menunggu persetujuan guru.'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
                icon: const Icon(Icons.send, size: 18),
                label: Text('Ajukan Permohonan $roleLabel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label, icon, desc;
  final UserRole role, current;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.desc,
    required this.role,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = role == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppTheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary)),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge Chip
class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF9C63FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.military_tech, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Activity Tile
class _ActivityTile extends StatelessWidget {
  final ActivityItem activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isReply = activity.icon == 'reply';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isReply ? AppTheme.success : AppTheme.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isReply ? Icons.chat_bubble_outline : Icons.upload_outlined,
              size: 18,
              color: isReply ? AppTheme.success : AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(activity.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(_timeAgo(activity.time),
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }
}
