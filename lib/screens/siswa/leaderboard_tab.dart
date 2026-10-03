import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final board = provider.leaderboard;

    return Scaffold(
      appBar: AppBar(title: const Text('Peringkat Mentor')),
      body: Column(
        children: [
          // ── Top 3 Podium
          if (board.length >= 3)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 2nd
                  _PodiumItem(user: board[1], rank: 2, height: 90),
                  const SizedBox(width: 12),
                  // 1st
                  _PodiumItem(user: board[0], rank: 1, height: 120),
                  const SizedBox(width: 12),
                  // 3rd
                  _PodiumItem(user: board[2], rank: 3, height: 70),
                ],
              ),
            ),

          // ── Rest of list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: board.length > 3 ? board.length - 3 : 0,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final user = board[i + 3];
                final rank = i + 4;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text('$rank',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary)),
                  ),
                  title: Text(user.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(user.kelas),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${user.poin}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primary)),
                      const Text('poin',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final UserModel user;
  final int rank;
  final double height;

  const _PodiumItem(
      {required this.user, required this.rank, required this.height});

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: rank == 1 ? 30 : 24,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(user.name[0],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: rank == 1 ? 20 : 16,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          Text(user.name.split(' ').first,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text('${user.poin} poin',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(medals[rank - 1], style: const TextStyle(fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }
}
