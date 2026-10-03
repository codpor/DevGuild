import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';

class ClinicTab extends StatefulWidget {
  const ClinicTab({super.key});
  @override
  State<ClinicTab> createState() => _ClinicTabState();
}

class _ClinicTabState extends State<ClinicTab> {
  String _filter = 'Semua';
  final _searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser!;

    List<TicketModel> tickets = provider.allTickets;

    // filter by status
    if (_filter == 'Terbuka') {
      tickets = tickets.where((t) => t.status == TicketStatus.open).toList();
    } else if (_filter == 'Proses') {
      tickets =
          tickets.where((t) => t.status == TicketStatus.inProgress).toList();
    } else if (_filter == 'Solved') {
      tickets =
          tickets.where((t) => t.status == TicketStatus.solved).toList();
    }

    // search
    if (_searchC.text.isNotEmpty) {
      tickets = tickets
          .where((t) =>
              t.title.toLowerCase().contains(_searchC.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klinik Kode'),
        actions: [
          if (user.activeRole == UserRole.mentor ||
              user.activeRole == UserRole.moderator)
            Chip(
              label: Text(user.activeRole == UserRole.mentor
                  ? '🎓 Mentor Mode'
                  : '🛡️ Moderator Mode'),
              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
              labelStyle: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // ── Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchC,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Cari tiket error...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // ── Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: ['Semua', 'Terbuka', 'Proses', 'Solved']
                  .map((label) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == label,
                          onSelected: (_) =>
                              setState(() => _filter = label),
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: _filter == label
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // ── Ticket List
          Expanded(
            child: tickets.isEmpty
                ? const Center(
                    child: Text('Tidak ada tiket ditemukan',
                        style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _TicketCard(ticket: tickets[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketDialog(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Tiket',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final errorC = TextEditingController();
    String category = 'PHP & MySQL';
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Buat Tiket Baru',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: [
                    'PHP & MySQL',
                    'HTML & CSS',
                    'JavaScript',
                    'Python',
                    'Keamanan Web',
                    'Umum'
                  ]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setModalState(() => category = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleC,
                  decoration: const InputDecoration(labelText: 'Judul Error'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descC,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi Masalah',
                      alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: errorC,
                  maxLines: 2,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Pesan Error (opsional)',
                    alignLabelWithHint: true,
                    hintText: 'Paste error message disini...',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (titleC.text.isEmpty || descC.text.isEmpty) return;
                    provider.addTicket(TicketModel(
                      id: 't${DateTime.now().millisecondsSinceEpoch}',
                      authorId: user.id,
                      authorName: user.name,
                      authorKelas: user.kelas,
                      title: titleC.text,
                      description: descC.text,
                      errorCode: errorC.text,
                      category: category,
                      createdAt: DateTime.now(),
                      replies: [],
                    ));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tiket berhasil dibuat!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  child: const Text('Kirim Tiket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const _TicketCard({required this.ticket});

  Color get _statusColor {
    switch (ticket.status) {
      case TicketStatus.solved:
        return AppTheme.success;
      case TicketStatus.inProgress:
        return AppTheme.warning;
      case TicketStatus.open:
        return AppTheme.info;
    }
  }

  String get _statusLabel {
    switch (ticket.status) {
      case TicketStatus.solved:
        return 'Solved';
      case TicketStatus.inProgress:
        return 'Diproses';
      case TicketStatus.open:
        return 'Terbuka';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticket: ticket))),
      child: Card(
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
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(ticket.category,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                  ),
                  const Spacer(),
                  Text(_timeAgo(ticket.createdAt),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              Text(ticket.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              Text(ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('${ticket.authorName} · ${ticket.authorKelas}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('${ticket.replies.length} balasan',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
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

// ═══════════════════════════════════════════════
//  TICKET DETAIL SCREEN
// ═══════════════════════════════════════════════
class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;
  const TicketDetailScreen({super.key, required this.ticket});
  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _replyC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser!;
    final ticket = provider.allTickets
        .firstWhere((t) => t.id == widget.ticket.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Ticket info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusBadge(ticket.status),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(ticket.category,
                                  style: const TextStyle(fontSize: 12)),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(ticket.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(ticket.description,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, height: 1.5)),
                        if (ticket.errorCode.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(ticket.errorCode,
                                style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontFamily: 'monospace',
                                    fontSize: 12)),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                                '${ticket.authorName} · ${ticket.authorKelas}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Replies
                Text('${ticket.replies.length} Balasan',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...ticket.replies.map((reply) => _ReplyCard(
                      reply: reply,
                      ticket: ticket,
                      currentUser: user,
                      onAccept: () {
                        provider.markSolved(ticket.id, reply.id);
                      },
                    )),
                if (ticket.replies.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Belum ada balasan. Jadilah yang pertama!',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Reply input (hanya untuk Mentor / Guru)
          if (ticket.status != TicketStatus.solved && provider.canReplyToTicket())
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyC,
                      decoration: const InputDecoration(
                        hintText: 'Tulis balasan...',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {
                        if (_replyC.text.isEmpty) return;
                        provider.addReply(
                          ticket.id,
                          ReplyModel(
                            id: 'r${DateTime.now().millisecondsSinceEpoch}',
                            authorId: user.id,
                            authorName: user.name,
                            authorRole: user.activeRole,
                            content: _replyC.text,
                            createdAt: DateTime.now(),
                          ),
                        );
                        _replyC.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          // ── Info: hanya mentor yang bisa menjawab
          if (ticket.status != TicketStatus.solved && !provider.canReplyToTicket())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Hanya Mentor yang dapat menjawab tiket',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final ReplyModel reply;
  final TicketModel ticket;
  final UserModel currentUser;
  final VoidCallback onAccept;

  const _ReplyCard({
    required this.reply,
    required this.ticket,
    required this.currentUser,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = reply.isAccepted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAccepted
            ? AppTheme.success.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccepted ? AppTheme.success : Colors.grey.shade200,
          width: isAccepted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                child: Text(reply.authorName[0],
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(reply.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (reply.authorRole == UserRole.mentor) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Mentor',
                              style: TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                      if (reply.authorRole == UserRole.moderator) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Moderator',
                              style: TextStyle(
                                  color: AppTheme.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(_timeAgo(reply.createdAt),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
              const Spacer(),
              if (isAccepted)
                const Chip(
                  label: Text('✓ Jawaban Terbaik'),
                  backgroundColor: AppTheme.success,
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(reply.content,
              style: const TextStyle(height: 1.5, fontSize: 14)),
          if (!isAccepted &&
              ticket.authorId == currentUser.id &&
              ticket.status != TicketStatus.solved) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle_outline,
                    size: 16, color: AppTheme.success),
                label: const Text('Tandai Solved',
                    style: TextStyle(color: AppTheme.success)),
              ),
            ),
          ],
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

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TicketStatus.solved:
        color = AppTheme.success;
        label = 'Solved';
        break;
      case TicketStatus.inProgress:
        color = AppTheme.warning;
        label = 'Diproses';
        break;
      case TicketStatus.open:
        color = AppTheme.info;
        label = 'Terbuka';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
