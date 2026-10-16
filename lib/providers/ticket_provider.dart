// lib/providers/ticket_provider.dart
// Provider khusus manajemen tiket & balasan

import '../repositories/repository_notifier.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../constants/app_strings.dart';
import '../utils/result.dart';
import '../utils/validators.dart';
import 'auth_provider.dart';

class TicketProvider extends RepositoryNotifier {
  final AppRepository _repo;
  final AuthProvider _authProvider;

  TicketProvider(this._repo, this._authProvider) : super(_repo);

  // ────────────── Poin Config ──────────────
  static const int poinCreateTicket = 5;
  static const int poinReplyTicket = 10;
  static const int poinAcceptedReply = 25;

  // ────────────── Queries ──────────────
  List<TicketModel> get allTickets => _repo.getAllTickets();
  TicketModel? getTicketById(String ticketId) => _repo.getTicketById(ticketId);

  List<TicketModel> get openTickets => _repo
      .getAllTickets()
      .where((t) => t.status == TicketStatus.open)
      .toList();

  List<TicketModel> get pendingTickets => _repo
      .getAllTickets()
      .where((t) => t.status != TicketStatus.solved)
      .toList();

  // ────────────── Actions ──────────────

  Result<TicketModel> addTicket(TicketModel ticket) {
    final user = _authProvider.currentUser;
    if (user == null || ticket.authorId != user.id) {
      return const Failure('Silakan masuk dengan akun pemilik tiket.');
    }
    final error =
        Validators.validateRequired(ticket.title, 'Judul tiket') ??
        Validators.validateRequired(ticket.description, 'Deskripsi masalah');
    if (error != null) return Failure(error, code: 'INVALID_INPUT');
    if (ticket.id.trim().isEmpty || _repo.getTicketById(ticket.id) != null) {
      return const Failure('ID tiket kosong atau sudah digunakan.');
    }
    _repo.addTicket(ticket);

    _authProvider.addPoin(poinCreateTicket);
    _authProvider.incrementTicketsCreated();
    _authProvider.addActivity(
      ActivityItem(
        title: AppStrings.activityCreateTicket,
        description: ticket.title,
        time: DateTime.now(),
        icon: 'ticket',
      ),
    );

    notifyListeners();
    return Success(ticket);
  }

  Result<ReplyModel> addReply(String ticketId, ReplyModel reply) {
    final user = _authProvider.currentUser;
    if (user == null ||
        !_authProvider.canReplyToTicket() ||
        reply.authorId != user.id) {
      return const Failure('Akunmu tidak dapat mengirim balasan ini.');
    }
    final error = Validators.validateRequired(reply.content, 'Balasan');
    if (error != null) return Failure(error, code: 'INVALID_INPUT');
    final ticket = _repo.getTicketById(ticketId);
    if (ticket == null) {
      return const Failure('Tiket tidak ditemukan.', code: 'TICKET_NOT_FOUND');
    }
    if (ticket.status == TicketStatus.solved ||
        ticket.replies.any((r) => r.id == reply.id)) {
      return const Failure('Tiket sudah selesai atau balasan sudah dikirim.');
    }
    final firstReply = !ticket.replies.any((r) => r.authorId == user.id);
    ticket.replies.add(reply);

    if (ticket.status == TicketStatus.open) {
      ticket.status = TicketStatus.inProgress;
    }

    if (firstReply && ticket.authorId != user.id) {
      _authProvider.addPoin(poinReplyTicket);
      _authProvider.incrementTicketsAnswered();
    }
    _authProvider.addActivity(
      ActivityItem(
        title: AppStrings.activityReplyTicket,
        description: ticket.title,
        time: DateTime.now(),
        icon: 'reply',
      ),
    );

    notifyListeners();
    return Success(reply);
  }

  Result<ReplyModel> markSolved(String ticketId, String replyId) {
    final user = _authProvider.currentUser;
    final ticket = _repo.getTicketById(ticketId);
    if (user == null ||
        ticket == null ||
        ticket.authorId != user.id ||
        ticket.status == TicketStatus.solved) {
      return const Failure(
        'Hanya pemilik tiket aktif yang dapat memilih jawaban.',
      );
    }
    final reply = ticket.replies.where((r) => r.id == replyId).firstOrNull;
    if (reply == null ||
        reply.isAccepted ||
        reply.authorId == ticket.authorId) {
      return const Failure('Pilih balasan orang lain yang belum diterima.');
    }
    ticket.status = TicketStatus.solved;
    reply.isAccepted = true;
    _authProvider.addPoinToUser(reply.authorId, poinAcceptedReply);

    notifyListeners();
    return Success(reply);
  }

  // ────────────── Moderator Actions ──────────────

  Result<TicketModel> forceMarkSolved(String ticketId) {
    if (!_authProvider.canModerateTicket()) {
      return const Failure(
        'Hanya guru atau moderator aktif yang dapat menutup tiket.',
      );
    }
    final ticket = _repo.getTicketById(ticketId);
    if (ticket == null) {
      return const Failure('Tiket tidak ditemukan.', code: 'TICKET_NOT_FOUND');
    }
    ticket.status = TicketStatus.solved;
    notifyListeners();
    return Success(ticket);
  }

  Result<TicketModel> deleteReply(String ticketId, String replyId) {
    if (!_authProvider.canModerateTicket()) {
      return const Failure(
        'Hanya guru atau moderator aktif yang dapat menghapus balasan.',
      );
    }
    final ticket = _repo.getTicketById(ticketId);
    if (ticket == null) {
      return const Failure('Tiket tidak ditemukan.', code: 'TICKET_NOT_FOUND');
    }
    if (!ticket.replies.any((reply) => reply.id == replyId)) {
      return const Failure('Balasan tidak ditemukan.', code: 'REPLY_NOT_FOUND');
    }
    ticket.replies.removeWhere((r) => r.id == replyId);
    notifyListeners();
    return Success(ticket);
  }

  Result<TicketModel> updateTicketTitle(String ticketId, String newTitle) {
    if (!_authProvider.canModerateTicket()) {
      return const Failure(
        'Hanya guru atau moderator aktif yang dapat mengubah judul tiket.',
      );
    }
    final ticket = _repo.getTicketById(ticketId);
    if (ticket == null) {
      return const Failure('Tiket tidak ditemukan.', code: 'TICKET_NOT_FOUND');
    }
    final error = Validators.validateRequired(newTitle, 'Judul tiket');
    if (error != null) return Failure(error, code: 'INVALID_INPUT');
    ticket.title = newTitle.trim();
    notifyListeners();
    return Success(ticket);
  }
}
