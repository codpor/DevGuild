import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/providers/role_provider.dart';
import 'package:devguild/providers/ticket_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/screens/siswa/clinic_tab.dart';
import 'package:devguild/screens/siswa/showcase_tab.dart';
import 'package:devguild/utils/result.dart';

class _RemovableRepository extends MockRepository {
  bool removed = false;
  @override
  List<ProjectModel> getAllProjects() => removed ? [] : super.getAllProjects();
  @override
  List<TicketModel> getAllTickets() => removed ? [] : super.getAllTickets();
  @override
  ProjectModel? getProjectById(String id) =>
      removed ? null : super.getProjectById(id);
  @override
  TicketModel? getTicketById(String id) =>
      removed ? null : super.getTicketById(id);
}

void main() {
  late _RemovableRepository repo;
  late AuthProvider auth;
  late ProjectProvider projects;
  late TicketProvider tickets;
  late RoleProvider roles;

  setUp(() {
    repo = _RemovableRepository();
    auth = AuthProvider(repo);
    projects = ProjectProvider(repo, auth);
    tickets = TicketProvider(repo, auth);
    roles = RoleProvider(repo, auth);
  });
  tearDown(() {
    roles.dispose();
    tickets.dispose();
    projects.dispose();
    auth.dispose();
  });

  test(
    'unknown repository IDs return null, existing IDs still return data',
    () {
      for (final id in ['', 'missing']) {
        expect(repo.getUserById(id), isNull);
        expect(repo.getTicketById(id), isNull);
        expect(repo.getProjectById(id), isNull);
        expect(repo.getRoleRequestById(id), isNull);
      }
      expect(repo.getTicketById('t1')!.id, 't1');
      expect(repo.getProjectById('p1')!.id, 'p1');
      expect(repo.getUserById('u1')!.role, 'Guru');
    },
  );

  test(
    'missing project actions fail without changing points, likes or activity',
    () {
      auth.login('9999', 'admin123');
      final author = repo.getUserById('u3')!;
      final beforePoints = author.poin;
      final beforeLikes = repo.getProjectById('p1')!.likes;
      final activities = List.of(author.activities);
      var changes = 0;
      projects.addListener(() => changes++);
      for (final approved in [true, false]) {
        final result = projects.validateProject('missing', approved);
        expect(result, isA<Failure<ProjectModel>>());
        expect((result as Failure<ProjectModel>).code, 'PROJECT_NOT_FOUND');
      }
      auth.login('2202', 'password123');
      final liked = Set.of(auth.currentUser!.likedProjects);
      final result = projects.toggleLikeProject('missing');
      expect(result, isA<Failure<ProjectModel>>());
      expect((result as Failure<ProjectModel>).code, 'PROJECT_NOT_FOUND');
      expect(author.poin, beforePoints);
      expect(author.activities, activities);
      expect(repo.getProjectById('p1')!.likes, beforeLikes);
      expect(auth.currentUser!.likedProjects, liked);
      expect(changes, 0);
    },
  );

  for (final nis in ['9999', '1003']) {
    test('authorized $nis gets failures for missing moderation targets', () {
      auth.login(nis, nis == '9999' ? 'admin123' : 'password123');
      final ticket = repo.getTicketById('t2')!;
      final title = ticket.title;
      final status = ticket.status;
      final replies = List.of(ticket.replies);
      var changes = 0;
      tickets.addListener(() => changes++);
      final results = [
        tickets.forceMarkSolved('missing'),
        tickets.updateTicketTitle('missing', 'Judul baru'),
        tickets.deleteReply('missing', 'r1'),
      ];
      for (final result in results) {
        expect(result, isA<Failure<TicketModel>>());
        expect((result as Failure<TicketModel>).code, 'TICKET_NOT_FOUND');
      }
      final missingReply = tickets.deleteReply('t2', 'missing');
      expect(missingReply, isA<Failure<TicketModel>>());
      expect((missingReply as Failure<TicketModel>).code, 'REPLY_NOT_FOUND');
      expect(ticket.title, title);
      expect(ticket.status, status);
      expect(ticket.replies, replies);
      expect(changes, 0);
    });
  }

  test('valid moderation still edits, deletes replies and closes tickets', () {
    auth.login('1003', 'password123');
    final ticket = repo.getTicketById('t3')!;
    expect(
      tickets.updateTicketTitle('t3', '  Judul baru  '),
      isA<Success<TicketModel>>(),
    );
    expect(ticket.title, 'Judul baru');
    expect(tickets.updateTicketTitle('t3', '  '), isA<Failure<TicketModel>>());
    expect(ticket.title, 'Judul baru');
    expect(tickets.deleteReply('t3', 'r2'), isA<Success<TicketModel>>());
    expect(ticket.replies, isEmpty);
    expect(tickets.forceMarkSolved('t3'), isA<Success<TicketModel>>());
    expect(ticket.status, TicketStatus.solved);
  });

  test('unknown reply and ticket cannot receive accepted-answer points', () {
    auth.login('2202', 'password123');
    final before = repo.getUserById('u3')!.poin;
    tickets.markSolved('missing', 'r1');
    tickets.markSolved('t3', 'missing');
    expect(repo.getTicketById('t3')!.status, TicketStatus.inProgress);
    expect(repo.getUserById('u3')!.poin, before);
  });

  Widget app(Widget screen) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: projects),
      ChangeNotifierProvider.value(value: tickets),
    ],
    child: MaterialApp(home: screen),
  );

  testWidgets('ticket detail shows an empty state when the ticket disappears', (
    tester,
  ) async {
    auth.login('2202', 'password123');
    final original = repo.getTicketById('t2')!;
    await tester.pumpWidget(app(TicketDetailScreen(ticket: original)));
    expect(find.text(original.title), findsOneWidget);
    repo.removed = true;
    await tester.pumpWidget(app(TicketDetailScreen(ticket: original)));
    await tester.pumpAndSettle();
    expect(find.text('Tiket tidak ditemukan.'), findsOneWidget);
    expect(find.text(original.title), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('project detail stops displaying stale data after removal', (
    tester,
  ) async {
    auth.login('2202', 'password123');
    final original = repo.getProjectById('p1')!;
    await tester.pumpWidget(app(ProjectDetailScreen(project: original)));
    expect(find.text(original.title), findsOneWidget);
    repo.removed = true;
    await tester.pumpWidget(app(ProjectDetailScreen(project: original)));
    await tester.pumpAndSettle();
    expect(find.text('Karya tidak ditemukan.'), findsOneWidget);
    expect(find.text(original.title), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
