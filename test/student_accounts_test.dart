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
import 'package:devguild/utils/password_hasher.dart';
import 'package:devguild/utils/result.dart';

void main() {
  late MockRepository repo;
  late AuthProvider auth;
  late ProjectProvider projects;
  late TicketProvider tickets;
  late RoleProvider roles;
  setUp(() {
    repo = MockRepository();
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
  void guru() => auth.login('9999', 'admin123');

  test('accounts are active by default', () {
    expect(repo.getAllSiswa().every((student) => student.isActive), isTrue);
  });
  test('anonymous and student roles cannot manage accounts', () {
    expect(
      auth.resetStudentPassword('u4', 'newpass123'),
      isA<Failure<UserModel>>(),
    );
    expect(auth.setStudentActive('u4', false), isA<Failure<UserModel>>());
    for (final nis in ['2202', '2201', '1003']) {
      auth.login(nis, 'password123');
      expect(auth.canManageStudents, isFalse);
      expect(
        auth.resetStudentPassword('u4', 'newpass123'),
        isA<Failure<UserModel>>(),
      );
      expect(auth.setStudentActive('u4', false), isA<Failure<UserModel>>());
      auth.logout();
    }
    expect(repo.getUserById('u4')!.isActive, isTrue);
    expect(
      PasswordHasher.verify('password123', repo.getUserById('u4')!.password),
      isTrue,
    );
  });
  test('inactive teacher cannot manage accounts', () {
    guru();
    repo.getUserById('u1')!.isActive = false;
    expect(auth.currentUser, isNull);
    expect(auth.canManageStudents, isFalse);
    expect(
      auth.resetStudentPassword('u4', 'newpass123'),
      isA<Failure<UserModel>>(),
    );
    expect(auth.setStudentActive('u4', false), isA<Failure<UserModel>>());
  });
  test('teacher credentials and unknown IDs cannot be changed', () {
    guru();
    for (final id in ['u1', 'missing']) {
      expect(
        auth.resetStudentPassword(id, 'newpass123'),
        isA<Failure<UserModel>>(),
      );
      expect(auth.setStudentActive(id, false), isA<Failure<UserModel>>());
    }
    expect(repo.getUserById('u1')!.isActive, isTrue);
    expect(
      PasswordHasher.verify('admin123', repo.getUserById('u1')!.password),
      isTrue,
    );
  });
  test('invalid passwords leave stored credentials unchanged', () {
    guru();
    final student = repo.getUserById('u4')!;
    final original = student.password;
    for (final password in ['', 'abc', '      ']) {
      expect(
        auth.resetStudentPassword('u4', password),
        isA<Failure<UserModel>>(),
      );
      expect(student.password, original);
    }
  });
  test('password reset stores a hash and changes login credentials', () {
    guru();
    final student = repo.getUserById('u4')!;
    expect(
      auth.resetStudentPassword('u4', 'newpass123'),
      isA<Success<UserModel>>(),
    );
    expect(student.password, isNot('newpass123'));
    expect(PasswordHasher.verify('newpass123', student.password), isTrue);
    expect(student.activities.first.title, 'Password Direset');
    expect(
      student.activities.any(
        (activity) =>
            activity.title.contains('newpass123') ||
            activity.description.contains('newpass123'),
      ),
      isFalse,
    );
    auth.logout();
    expect(auth.login('2202', 'password123'), isA<Failure<UserModel>>());
    expect(auth.login('2202', 'newpass123'), isA<Success<UserModel>>());
  });
  test('deactivation blocks login and reactivation restores it', () {
    guru();
    auth.setStudentActive('u4', false);
    auth.logout();
    final denied = auth.login('2202', 'password123');
    expect(denied, isA<Failure<UserModel>>());
    expect((denied as Failure<UserModel>).code, 'ACCOUNT_INACTIVE');
    expect(auth.currentUser, isNull);
    guru();
    auth.setStudentActive('u4', true);
    auth.logout();
    expect(auth.login('2202', 'password123'), isA<Success<UserModel>>());
  });
  test('repeated status decisions do not duplicate activity', () {
    guru();
    final student = repo.getUserById('u4')!;
    final before = student.activities.length;
    auth.setStudentActive('u4', false);
    auth.setStudentActive('u4', false);
    expect(student.activities.length, before + 1);
    auth.setStudentActive('u4', true);
    auth.setStudentActive('u4', true);
    expect(student.activities.length, before + 2);
  });
  test('account operations preserve contributions and prevent duplicate NIS registration', () {
    guru();
    final student = repo.getUserById('u4')!;
    final beforePoints = student.poin;
    final beforeBadges = [...student.badges];
    final beforeProjects = repo.getAllProjects().length;
    final beforeTickets = repo.getAllTickets().length;
    auth.setStudentActive('u4', false);
    auth.resetStudentPassword('u4', 'newpass123');
    expect(student.poin, beforePoints);
    expect(student.badges, beforeBadges);
    expect(repo.getAllProjects().length, beforeProjects);
    expect(repo.getAllTickets().length, beforeTickets);
    expect(
      auth.register(
        nis: '2202',
        name: 'Duplikat',
        kelas: 'X',
        password: 'test123',
      ),
      isA<Failure<UserModel>>(),
    );
  });
  test('a disabled account cannot continue using authorization checks', () {
    final session = AuthProvider(repo);
    addTearDown(session.dispose);
    session.login('2201', 'password123');
    expect(session.canReplyToTicket(), isTrue);
    guru();
    auth.setStudentActive('u3', false);
    expect(session.currentUser, isNull);
    expect(session.canReplyToTicket(), isFalse);
    expect(session.canModerateTicket(), isFalse);
    expect(
      session.updateProfilePhoto(null, userId: 'u3'),
      isA<Failure<UserModel>>(),
    );
  });

  Widget app(Widget screen) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: projects),
      ChangeNotifierProvider.value(value: tickets),
      ChangeNotifierProvider.value(value: roles),
    ],
    child: MaterialApp(home: screen),
  );

  Future<void> start(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    guru();
    await tester.pumpWidget(app(const GuruManajemen()));
    await tester.pumpAndSettle();
  }

  Future<void> menu(WidgetTester tester, String label) async {
    final button = find.byType(PopupMenuButton<String>).at(2);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('reset dialog validates confirmation before saving', (
    tester,
  ) async {
    await start(tester);
    final original = repo.getUserById('u4')!.password;
    await menu(tester, 'Reset Password');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password Baru'),
      'newpass123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
      'wrong123',
    );
    await tester.tap(find.text('Simpan Password'));
    await tester.pumpAndSettle();
    expect(find.text('Password tidak cocok'), findsOneWidget);
    expect(repo.getUserById('u4')!.password, original);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
      'newpass123',
    );
    await tester.tap(find.text('Simpan Password'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      PasswordHasher.verify('newpass123', repo.getUserById('u4')!.password),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('canceling password reset leaves credentials unchanged', (
    tester,
  ) async {
    await start(tester);
    final original = repo.getUserById('u4')!.password;
    await menu(tester, 'Reset Password');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password Baru'),
      'newpass123',
    );
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(repo.getUserById('u4')!.password, original);
  });
  testWidgets(
    'status changes require confirmation and menu supports reactivation',
    (tester) async {
      await start(tester);
      await menu(tester, 'Nonaktifkan Akun');
      expect(repo.getUserById('u4')!.isActive, isTrue);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(repo.getUserById('u4')!.isActive, isTrue);
      await menu(tester, 'Nonaktifkan Akun');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(repo.getUserById('u4')!.isActive, isFalse);
      expect(find.text('Nonaktif'), findsOneWidget);
      await menu(tester, 'Aktifkan Akun');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(repo.getUserById('u4')!.isActive, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('dialog rechecks teacher permission at save time', (
    tester,
  ) async {
    await start(tester);
    final original = repo.getUserById('u4')!.password;
    await menu(tester, 'Reset Password');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password Baru'),
      'newpass123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
      'newpass123',
    );
    auth.logout();
    await tester.pump();
    await tester.tap(find.text('Simpan Password'));
    await tester.pumpAndSettle();
    expect(
      find.text('Hanya guru aktif yang dapat mereset password.'),
      findsOneWidget,
    );
    expect(repo.getUserById('u4')!.password, original);
  });
  testWidgets('student detail displays account status and actions', (
    tester,
  ) async {
    guru();
    await tester.pumpWidget(app(const StudentDetailScreen(studentId: 'u4')));
    expect(find.text('Status Akun: Aktif'), findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Nonaktifkan Akun'), findsOneWidget);
    auth.setStudentActive('u4', false);
    await tester.pumpAndSettle();
    expect(find.text('Status Akun: Nonaktif'), findsOneWidget);
    expect(find.text('Aktifkan Akun'), findsOneWidget);
  });
}
