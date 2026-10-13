import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/providers/role_provider.dart';
import 'package:devguild/providers/ticket_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/screens/guru/guru_manajemen.dart';
import 'package:devguild/screens/guru/student_detail_screen.dart';
import 'package:devguild/screens/siswa/my_projects_tab.dart';
import 'package:devguild/screens/siswa/project_revision_screen.dart';
import 'package:devguild/screens/siswa/siswa_home.dart';

void main() {
  late MockRepository repo;
  late AuthProvider auth;
  late ProjectProvider projects;
  late TicketProvider tickets;
  late RoleProvider roles;
  late List<ActivityItem> initialActivities;

  setUp(() {
    repo = MockRepository();
    auth = AuthProvider(repo);
    projects = ProjectProvider(repo, auth);
    tickets = TicketProvider(repo, auth);
    roles = RoleProvider(repo, auth);
    initialActivities = [...repo.getUserById('u4')!.activities];
  });
  tearDown(() {
    repo.getUserById('u4')!.activities
      ..clear()
      ..addAll(initialActivities);
    roles.dispose();
    tickets.dispose();
    projects.dispose();
    auth.dispose();
  });
  Widget app(Widget child) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: projects),
      ChangeNotifierProvider.value(value: tickets),
      ChangeNotifierProvider.value(value: roles),
    ],
    child: MaterialApp(home: child),
  );

  testWidgets('student navigation opens Karya Saya', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    auth.login('2202', 'password123');
    await tester.pumpWidget(app(const SiswaHome()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karya Saya').last);
    await tester.pumpAndSettle();
    expect(find.text('Website Portofolio Personal'), findsOneWidget);
    expect(find.text('Aplikasi Kasir Sederhana'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters show only the selected status', (tester) async {
    auth.login('2202', 'password123');
    repo.addProject(
      ProjectModel(
        id: 'rejected-own',
        authorId: 'u4',
        authorName: 'Siti Rahayu',
        authorKelas: 'XI PPLG 2',
        title: 'Karya Ditolak',
        description: 'Demo',
        isRejected: true,
        guruFeedback: 'Perbaiki demo',
        createdAt: DateTime.now(),
      ),
    );
    repo.addProject(
      ProjectModel(
        id: 'approved-own',
        authorId: 'u4',
        authorName: 'Siti Rahayu',
        authorKelas: 'XI PPLG 2',
        title: 'Karya Disetujui',
        description: 'Demo',
        isValidated: true,
        createdAt: DateTime.now(),
      ),
    );
    await tester.pumpWidget(app(const MyProjectsTab()));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ditolak'));
    await tester.pumpAndSettle();
    expect(find.text('Karya Ditolak'), findsOneWidget);
    expect(find.text('Perbaiki demo'), findsOneWidget);
    expect(find.text('Karya Disetujui'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Disetujui'));
    await tester.pumpAndSettle();
    expect(find.text('Karya Disetujui'), findsOneWidget);
    expect(find.text('Revisi Karya'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Menunggu Review'));
    await tester.pumpAndSettle();
    expect(find.text('Website Portofolio Personal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejected project is edited and sent back to teacher review', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    auth.login('9999', 'admin123');
    projects.validateProject('p3', false, feedback: 'Lengkapi deskripsi');
    auth.logout();
    auth.login('2202', 'password123');
    await tester.pumpWidget(app(const MyProjectsTab()));
    await tester.tap(find.text('Revisi Karya'));
    await tester.pumpAndSettle();
    expect(find.text('Lengkapi deskripsi'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Karya'),
      'Portofolio Baru',
    );
    await tester.scrollUntilVisible(
      find.text('Kirim Revisi'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Kirim Revisi'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kirim Revisi'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectRevisionScreen), findsNothing);
    expect(find.text('Portofolio Baru'), findsOneWidget);
    expect(find.text('Catatan guru sebelumnya'), findsOneWidget);
    expect(find.text('Revisi Karya'), findsNothing);
    expect(
      projects.pendingProjects.map((project) => project.id),
      contains('p3'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('teacher student menu opens a real detail screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    auth.login('9999', 'admin123');
    await tester.pumpWidget(app(const GuruManajemen()));
    await tester.tap(find.byType(PopupMenuButton<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Detail'));
    await tester.pumpAndSettle();
    expect(find.byType(StudentDetailScreen), findsOneWidget);
    expect(find.text('Siti Rahayu'), findsOneWidget);
    expect(find.text('NIS: 2202'), findsOneWidget);
    expect(find.text('Kelas: XI PPLG 2'), findsOneWidget);
    expect(find.text('Statistik Kontribusi'), findsOneWidget);
    expect(find.text('Website Portofolio Personal'), findsOneWidget);
    expect(find.text('Aplikasi Kasir Sederhana'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail handles unknown students and denies student access', (
    tester,
  ) async {
    auth.login('9999', 'admin123');
    await tester.pumpWidget(
      app(const StudentDetailScreen(studentId: 'missing')),
    );
    expect(find.text('Siswa tidak ditemukan.'), findsOneWidget);
    auth.logout();
    auth.login('2202', 'password123');
    await tester.pumpWidget(app(const StudentDetailScreen(studentId: 'u3')));
    await tester.pumpAndSettle();
    expect(find.text('Detail siswa hanya dapat diakses guru.'), findsOneWidget);
    expect(find.text('Arif Fakhry'), findsNothing);
  });

  testWidgets('empty work list explains where to submit a project', (
    tester,
  ) async {
    auth.login('1001', 'password123');
    await tester.pumpWidget(app(const MyProjectsTab()));
    expect(
      find.text(
        'Belum ada karya. Kirim karya melalui tombol tambah di Showcase.',
      ),
      findsOneWidget,
    );
  });
}
