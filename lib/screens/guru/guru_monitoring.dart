import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../siswa/clinic_tab.dart';

class GuruMonitoring extends StatelessWidget {
  const GuruMonitoring({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TicketProvider>(context);
    final tickets = provider.allTickets;
    final openT = tickets.where((t) => t.status == TicketStatus.open).toList();
    final inProgT =
        tickets.where((t) => t.status == TicketStatus.inProgress).toList();
    final solvedT =
        tickets.where((t) => t.status == TicketStatus.solved).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Klinik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status summary
            Row(
              children: [
                _MonitorCard(
                    label: 'Terbuka',
                    count: openT.length,
                    color: AppTheme.info),
                const SizedBox(width: 10),
                _MonitorCard(
                    label: 'Diproses',
                    count: inProgT.length,
                    color: AppTheme.warning),
                const SizedBox(width: 10),
                _MonitorCard(
                    label: 'Solved',
                    count: solvedT.length,
                    color: AppTheme.success),
              ],
            ),
            const SizedBox(height: 20),

            // ── Urgent: open tickets
            if (openT.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Perlu Perhatian — Belum Ada Jawaban',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              ...openT.map((t) => _MonitoringTicketTile(ticket: t)),
              const SizedBox(height: 20),
            ],

            // ── In progress
            if (inProgT.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Sedang Diproses',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              ...inProgT.map((t) => _MonitoringTicketTile(ticket: t)),
              const SizedBox(height: 20),
            ],

            // ── Solved
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                const Text('Sudah Terselesaikan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),
            ...solvedT.map((t) => _MonitoringTicketTile(ticket: t)),
          ],
        ),
      ),
    );
  }
}

class _MonitorCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _MonitorCard(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style:
                    TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MonitoringTicketTile extends StatelessWidget {
  final TicketModel ticket;
  const _MonitoringTicketTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = AppTheme.info;
        break;
      case TicketStatus.inProgress:
        statusColor = AppTheme.warning;
        break;
      case TicketStatus.solved:
        statusColor = AppTheme.success;
        break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticket: ticket),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                        '${ticket.authorName} · ${ticket.replies.length} balasan',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text(ticket.category,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
