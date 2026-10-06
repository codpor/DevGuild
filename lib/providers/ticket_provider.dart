// lib/providers/ticket_provider.dart
// Provider khusus manajemen tiket & balasan

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../constants/app_strings.dart';
import 'auth_provider.dart';

class TicketProvider with ChangeNotifier {
  final AppRepository _repo;
  final AuthProvider _authProvider;

  TicketProvider(this._repo, this._authProvider);

  // ────────────── Poin Config ──────────────
  static const int poinCreateTicket = 5;
  static const int poinReplyTicket = 10;
  static const int poinAcceptedReply = 25;

  // ────────────── Queries ──────────────
  List<TicketModel> get allTickets => _repo.getAllTickets();

  List<TicketModel> get openTickets =>
      _repo.getAllTickets().where((t) => t.status == TicketStatus.open).toList();

  List<TicketModel> get pendingTickets =>
      _repo
          .getAllTickets()
          .where((t) => t.status != TicketStatus.solved)
          .toList();

  // ────────────── Actions ──────────────

  void addTicket(TicketModel ticket) {
    _repo.addTicket(ticket);

    _authProvider.addPoin(poinCreateTicket);
    _authProvider.incrementTicketsCreated();
    _authProvider.addActivity(ActivityItem(
      title: AppStrings.activityCreateTicket,
      description: ticket.title,
      time: DateTime.now(),
      icon: 'ticket',
    ));

    notifyListeners();
  }

  void addReply(String ticketId, ReplyModel reply) {
    final ticket = _repo.getTicketById(ticketId);
    ticket.replies.add(reply);

    if (ticket.status == TicketStatus.open) {
      ticket.status = TicketStatus.inProgress;
    }

    _authProvider.addPoin(poinReplyTicket);
    _authProvider.incrementTicketsAnswered();
    _authProvider.addActivity(ActivityItem(
      title: AppStrings.activityReplyTicket,
      description: ticket.title,
      time: DateTime.now(),
      icon: 'reply',
    ));

    notifyListeners();
  }

  void markSolved(String ticketId, String replyId) {
    final ticket = _repo.getTicketById(ticketId);
    ticket.status = TicketStatus.solved;
    final reply = ticket.replies.firstWhere((r) => r.id == replyId);
    reply.isAccepted = true;

    // Bonus poin untuk yang menjawab
    _authProvider.addPoinToUser(reply.authorId, poinAcceptedReply);

    notifyListeners();
  }

  // ────────────── Moderator Actions ──────────────

  void forceMarkSolved(String ticketId) {
    if (!_authProvider.canModerateTicket()) return;
    final ticket = _repo.getTicketById(ticketId);
    ticket.status = TicketStatus.solved;
    notifyListeners();
  }

  void deleteReply(String ticketId, String replyId) {
    if (!_authProvider.canModerateTicket()) return;
    final ticket = _repo.getTicketById(ticketId);
    ticket.replies.removeWhere((r) => r.id == replyId);
    notifyListeners();
  }

  void updateTicketTitle(String ticketId, String newTitle) {
    if (!_authProvider.canModerateTicket()) return;
    final ticket = _repo.getTicketById(ticketId);
    ticket.title = newTitle;
    notifyListeners();
  }
}
