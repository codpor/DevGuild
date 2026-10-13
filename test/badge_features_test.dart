import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/providers/ticket_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/screens/siswa/achievements_screen.dart';
import 'package:devguild/services/badge_service.dart';

void main() {
  late MockRepository repo;
  late AuthProvider auth;
  late ProjectProvider projects;
  late TicketProvider tickets;
  late UserModel student;
  setUp(() {
    repo = MockRepository();
    auth = AuthProvider(repo);
    projects = ProjectProvider(repo, auth);
    tickets = TicketProvider(repo, auth);
    auth.register(
      nis: '8888',
      name: 'Siswa Baru',
      kelas: 'XI PPLG 1',
      password: 'test123',
    );
    student = auth.currentUser!;
  });
  tearDown(() {
    projects.dispose();
    tickets.dispose();
    auth.dispose();
  });
  TicketModel ticket(String id, String author) => TicketModel(
    id: id,
    authorId: author,
    authorName: 'Penanya',
    authorKelas: 'XI PPLG 1',
    title: 'Pertanyaan $id',
    description: 'Masalah kode',
    createdAt: DateTime.now(),
  );
  ReplyModel reply(String id) => ReplyModel(
    id: id,
    authorId: student.id,
    authorName: student.name,
    authorRole: UserRole.mentor,
    content: 'Coba solusi ini',
    createdAt: DateTime.now(),
  );
  ProjectModel project(String id) => ProjectModel(
    id: id,
    authorId: student.id,
    authorName: student.name,
    authorKelas: student.kelas,
    title: 'Karya $id',
    description: 'Demo',
    createdAt: DateTime.now(),
  );

  test('badge list is mutable and initial input is copied', () {
    const initial = ['Legacy'];
    final user = UserModel(
      id: 'copy',
      nis: '1234',
      name: 'Demo',
      kelas: 'X',
      role: 'Siswa',
      badges: initial,
    );
    user.badges.add('New');
    expect(initial, ['Legacy']);
    expect(user.badges, ['Legacy', 'New']);
  });

  test('repository instances do not share badge or activity mutations', () {
    final first = repo.getUserById('u4')!;
    first.badges.add('Test Badge');
    first.activities.clear();
    final second = MockRepository().getUserById('u4')!;
    expect(second.badges, isNot(contains('Test Badge')));
    expect(second, isNot(same(first)));
  });

  test('large seeded counters do not unlock contribution badges', () {
    student.ticketsCreated = 999;
    student.ticketsAnswered = 999;
    student.poin = 9999;
    auth.addPoin(0);
    expect(student.badges, isEmpty);
    expect(
      auth.achievementProgress.every((badge) => badge.current == 0),
      isTrue,
    );
  });

  test('three real tickets award Penanya Aktif once', () {
    tickets.addTicket(ticket('new1', student.id));
    tickets.addTicket(ticket('new2', student.id));
    expect(student.badges, isEmpty);
    tickets.addTicket(ticket('new3', student.id));
    expect(student.badges, contains('Penanya Aktif'));
    final initialPoints = student.poin;
    tickets.addTicket(ticket('new3', student.id));
    auth.addPoin(0);
    auth.logout();
    auth.login('8888', 'test123');
    expect(student.poin, initialPoints);
    expect(student.badges.where((b) => b == 'Penanya Aktif').length, 1);
    expect(
      student.activities
          .where(
            (a) =>
                a.title == 'Mendapat Badge' && a.description == 'Penanya Aktif',
          )
          .length,
      1,
    );
  });

  test('repeated replies on one ticket do not unlock Rekan Belajar', () {
    student.activeRole = UserRole.mentor;
    repo.addTicket(ticket('other1', 'u4'));
    for (var i = 0; i < 4; i++) {
      tickets.addReply('other1', reply('answer$i'));
    }
    expect(student.badges, isNot(contains('Rekan Belajar')));
    expect(student.ticketsAnswered, 1);
    expect(student.poin, TicketProvider.poinReplyTicket);
    repo.addTicket(ticket('other2', 'u4'));
    repo.addTicket(ticket('other3', 'u4'));
    tickets.addReply('other2', reply('answer4'));
    tickets.addReply('other3', reply('answer5'));
    expect(student.badges, contains('Rekan Belajar'));
    expect(student.ticketsAnswered, 3);
  });

  test('unauthorized or forged replies cannot contribute toward badges', () {
    repo.addTicket(ticket('other1', 'u4'));
    tickets.addReply('other1', reply('answer1'));
    expect(repo.getTicketById('other1').replies, isEmpty);
    student.activeRole = UserRole.mentor;
    tickets.addReply(
      'other1',
      ReplyModel(
        id: 'forged',
        authorId: 'u3',
        authorName: 'Wrong',
        content: 'Fake',
        createdAt: DateTime.now(),
      ),
    );
    tickets.addReply('missing', reply('unknown'));
    expect(repo.getTicketById('other1').replies, isEmpty);
    expect(student.poin, 0);
  });

  test('accepted answer awards badge and points only once', () {
    student.activeRole = UserRole.mentor;
    repo.addTicket(ticket('other1', 'u4'));
    tickets.addReply('other1', reply('accepted'));
    final before = student.poin;
    tickets.markSolved('other1', 'accepted');
    expect(repo.getTicketById('other1').status, TicketStatus.inProgress);
    auth.logout();
    auth.login('2202', 'password123');
    tickets.markSolved('other1', 'missing');
    expect(repo.getTicketById('other1').status, TicketStatus.inProgress);
    tickets.markSolved('other1', 'accepted');
    tickets.markSolved('other1', 'accepted');
    expect(student.badges, contains('Pemecah Masalah'));
    expect(student.poin, before + TicketProvider.poinAcceptedReply);
  });

  test('self answers never qualify as solved contributions', () {
    student.activeRole = UserRole.mentor;
    tickets.addTicket(ticket('own', student.id));
    tickets.addReply('own', reply('self-answer'));
    tickets.markSolved('own', 'self-answer');
    expect(student.badges, isNot(contains('Pemecah Masalah')));
    expect(student.ticketsAnswered, 0);
    expect(student.poin, TicketProvider.poinCreateTicket);
  });

  test('only approved projects unlock creator badges', () {
    for (var i = 1; i <= 3; i++) {
      projects.addProject(project('work$i'));
    }
    expect(student.badges, isNot(contains('Kreator')));
    auth.logout();
    auth.login('9999', 'admin123');
    projects.validateProject('work1', false, feedback: 'Revisi');
    expect(student.badges, isNot(contains('Kreator')));
    projects.validateProject('work2', true);
    expect(student.badges, contains('Kreator'));
    expect(student.badges, isNot(contains('Kreator Produktif')));
    projects.validateProject('work3', true);
    repo.addProject(project('work4'));
    projects.validateProject('work4', true);
    expect(student.badges, contains('Kreator Produktif'));
  });

  test(
    'earned badges remain after contribution removal and no duplicates occur',
    () {
      for (var i = 0; i < 3; i++) {
        repo.addTicket(ticket('earned$i', student.id));
      }
      BadgeService.award(student, repo.getAllTickets(), []);
      BadgeService.award(student, [], []);
      expect(student.badges.where((b) => b == 'Penanya Aktif').length, 1);
    },
  );

  test('teachers do not receive student achievement badges', () {
    auth.logout();
    auth.login('9999', 'admin123');
    final guru = auth.currentUser!;
    expect(
      BadgeService.progress(guru, repo.getAllTickets(), repo.getAllProjects()),
      isEmpty,
    );
    expect(guru.badges, ['Admin', 'Founder']);
  });

  testWidgets('achievement screen displays real progress and earned state', (
    tester,
  ) async {
    tickets.addTicket(ticket('new1', student.id));
    tickets.addTicket(ticket('new2', student.id));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: projects),
          ChangeNotifierProvider.value(value: tickets),
        ],
        child: const MaterialApp(home: AchievementsScreen()),
      ),
    );
    expect(find.text('Penanya Aktif'), findsOneWidget);
    expect(find.text('Progres: 2/3'), findsOneWidget);
    tickets.addTicket(ticket('new3', student.id));
    await tester.pumpAndSettle();
    expect(find.text('Sudah diperoleh'), findsOneWidget);
    expect(find.text('Progres: 2/3'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
