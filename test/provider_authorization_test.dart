import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/providers/role_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/screens/siswa/showcase_tab.dart';
import 'package:devguild/utils/result.dart';

void main() {
  late MockRepository repo;
  late AuthProvider auth;
  late RoleProvider roles;
  late ProjectProvider projects;
  late UserModel student;

  setUp(() {
    repo = MockRepository();
    auth = AuthProvider(repo);
    roles = RoleProvider(repo, auth);
    projects = ProjectProvider(repo, auth);
    student = repo.getUserById('u3')!;
  });

  tearDown(() {
    projects.dispose();
    roles.dispose();
    auth.dispose();
  });

  RoleRequestModel seedRequest({
    String userId = 'u3',
    UserRole role = UserRole.mentor,
  }) {
    final request = RoleRequestModel(
      id: 'request',
      userId: userId,
      userName: student.name,
      userKelas: student.kelas,
      requestedRole: role,
      createdAt: DateTime.now(),
    );
    repo.addRoleRequest(request);
    return request;
  }

  ProjectModel work({
    String id = 'new-project',
    String authorId = 'u3',
    String? authorName,
    String? authorKelas,
  }) => ProjectModel(
    id: id,
    authorId: authorId,
    authorName: authorName ?? student.name,
    authorKelas: authorKelas ?? student.kelas,
    title: '  Karya baru  ',
    description: '  Deskripsi karya  ',
    category: 'Web',
    createdAt: DateTime(2000),
  );

  void expectUploadDenied(ProjectModel input) {
    final count = projects.allProjects.length;
    final activities = List.of(student.activities);
    final points = student.poin;
    var changes = 0;
    projects.addListener(() => changes++);
    expect(projects.addProject(input), isA<Failure<ProjectModel>>());
    expect(projects.allProjects.length, count);
    expect(student.activities, activities);
    expect(student.poin, points);
    expect(changes, 0);
  }

  group('role authorization', () {
    for (final account in ['anonymous', '2202', '2201', '1003', 'inactive']) {
      test('$account cannot approve or reject a role request', () {
        final request = seedRequest();
        final originalRole = student.activeRole;
        if (account == 'inactive') {
          auth.login('9999', 'admin123');
          auth.currentUser!.isActive = false;
        } else if (account != 'anonymous') {
          auth.login(account, 'password123');
        }
        var changes = 0;
        roles.addListener(() => changes++);
        expect(
          roles.approveRoleRequest(request.id),
          isA<Failure<RoleRequestModel>>(),
        );
        expect(
          roles.rejectRoleRequest(request.id, 'Ditolak'),
          isA<Failure<RoleRequestModel>>(),
        );
        expect(request.status, RoleRequestStatus.pending);
        expect(request.feedback, isEmpty);
        expect(student.activeRole, originalRole);
        expect(changes, 0);
      });
    }

    test('active teacher approves once and cannot reverse the decision', () {
      student.activeRole = UserRole.mentee;
      final request = seedRequest();
      auth.login('9999', 'admin123');
      expect(
        roles.approveRoleRequest(request.id),
        isA<Success<RoleRequestModel>>(),
      );
      expect(student.activeRole, UserRole.mentor);
      expect(
        roles.approveRoleRequest(request.id),
        isA<Failure<RoleRequestModel>>(),
      );
      expect(
        roles.rejectRoleRequest(request.id, 'Ubah keputusan'),
        isA<Failure<RoleRequestModel>>(),
      );
      expect(request.status, RoleRequestStatus.approved);
      expect(request.feedback, isEmpty);
    });

    test('active teacher rejects once without changing student role', () {
      final request = seedRequest();
      final originalRole = student.activeRole;
      auth.login('9999', 'admin123');
      expect(
        roles.rejectRoleRequest(request.id, '  Lengkapi syarat  '),
        isA<Success<RoleRequestModel>>(),
      );
      expect(
        roles.approveRoleRequest(request.id),
        isA<Failure<RoleRequestModel>>(),
      );
      expect(
        roles.rejectRoleRequest(request.id, 'Ubah alasan'),
        isA<Failure<RoleRequestModel>>(),
      );
      expect(request.status, RoleRequestStatus.rejected);
      expect(request.feedback, 'Lengkapi syarat');
      expect(student.activeRole, originalRole);
    });

    test('unknown role requests return failures without throwing', () {
      auth.login('9999', 'admin123');
      expect(
        roles.approveRoleRequest('missing'),
        isA<Failure<RoleRequestModel>>(),
      );
      expect(
        roles.rejectRoleRequest('missing', ''),
        isA<Failure<RoleRequestModel>>(),
      );
    });

    for (final target in [
      'missing',
      'teacher',
      'inactive',
      'ineligible',
      'mentee',
    ]) {
      test('teacher cannot approve $target applicant or role', () {
        final request = seedRequest(
          userId: target == 'missing'
              ? 'missing'
              : target == 'teacher'
              ? 'u1'
              : 'u3',
          role: target == 'mentee' ? UserRole.mentee : UserRole.mentor,
        );
        if (target == 'inactive') student.isActive = false;
        if (target == 'ineligible') student.poin = 0;
        final originalRole = student.activeRole;
        auth.login('9999', 'admin123');
        expect(
          roles.approveRoleRequest(request.id),
          isA<Failure<RoleRequestModel>>(),
        );
        expect(request.status, RoleRequestStatus.pending);
        expect(student.activeRole, originalRole);
      });
    }

    test('eligible student applies once without granting their own role', () {
      auth.login('2201', 'password123');
      roles.switchToMentee();
      expect(
        roles.submitRoleRequest(UserRole.mentor),
        isA<Success<RoleRequestModel>>(),
      );
      expect(student.activeRole, UserRole.mentee);
      expect(
        roles.submitRoleRequest(UserRole.mentor),
        isA<Failure<RoleRequestModel>>(),
      );
      expect(roles.allRoleRequests.length, 1);
    });

    for (final account in ['anonymous', '9999', '2202', 'inactive']) {
      test('$account cannot bypass role application requirements', () {
        if (account == 'inactive') {
          auth.login('2201', 'password123');
          student.isActive = false;
        } else if (account != 'anonymous') {
          auth.login(account, account == '9999' ? 'admin123' : 'password123');
        }
        expect(
          roles.submitRoleRequest(UserRole.mentor),
          isA<Failure<RoleRequestModel>>(),
        );
        expect(roles.allRoleRequests, isEmpty);
      });
    }

    test(
      'student cannot request current role, mentee or ineligible moderator',
      () {
        auth.login('2201', 'password123');
        for (final role in UserRole.values) {
          expect(
            roles.submitRoleRequest(role),
            isA<Failure<RoleRequestModel>>(),
          );
        }
        expect(roles.allRoleRequests, isEmpty);
      },
    );
  });

  group('project submission authorization', () {
    for (final account in ['anonymous', 'teacher', 'inactive']) {
      test('$account cannot submit projects', () {
        if (account == 'teacher') auth.login('9999', 'admin123');
        if (account == 'inactive') {
          auth.login('2201', 'password123');
          student.isActive = false;
        }
        expectUploadDenied(work());
      });
    }

    for (final identity in ['id', 'name', 'class']) {
      test('forged author $identity is rejected', () {
        auth.login('2201', 'password123');
        expectUploadDenied(
          work(
            authorId: identity == 'id' ? 'u4' : student.id,
            authorName: identity == 'name' ? 'Orang lain' : student.name,
            authorKelas: identity == 'class' ? 'Kelas lain' : student.kelas,
          ),
        );
      });
    }

    for (final state in [
      'approved',
      'rejected',
      'feedback',
      'likes',
      'negative likes',
    ]) {
      test('forged initial $state is rejected', () {
        auth.login('2201', 'password123');
        final input = work();
        switch (state) {
          case 'approved':
            input.isValidated = true;
          case 'rejected':
            input.isRejected = true;
          case 'feedback':
            input.guruFeedback = 'Disetujui';
          case 'likes':
            input.likes = 20;
          case 'negative likes':
            input.likes = -1;
        }
        expectUploadDenied(input);
      });
    }

    for (final field in [
      'id',
      'duplicate',
      'title',
      'description',
      'category',
      'demo',
      'repository',
    ]) {
      test('invalid $field is rejected without side effects', () {
        auth.login('2201', 'password123');
        final input = work(
          id: field == 'id'
              ? '  '
              : field == 'duplicate'
              ? 'p1'
              : 'new-project',
        );
        switch (field) {
          case 'title':
            input.title = '  ';
          case 'description':
            input.description = '  ';
          case 'category':
            input.category = 'Unknown';
          case 'demo':
            input.linkAkses = 'javascript:alert(1)';
          case 'repository':
            input.linkGithub = 'not-a-url';
        }
        expectUploadDenied(input);
      });
    }

    test(
      'valid submission stays pending and only teacher review awards points',
      () {
        auth.login('2201', 'password123');
        final input = work()..teamMembers = ['Arif'];
        final initialPoints = student.poin;
        final initialActivities = student.activities.length;
        expect(projects.addProject(input), isA<Success<ProjectModel>>());
        final saved = repo.getProjectById(input.id);
        expect(saved.title, 'Karya baru');
        expect(saved.description, 'Deskripsi karya');
        expect(saved.createdAt.isAfter(input.createdAt), isTrue);
        input.isValidated = true;
        input.likes = 100;
        input.teamMembers.add('Palsu');
        expect(saved.isValidated, isFalse);
        expect(saved.isRejected, isFalse);
        expect(saved.likes, 0);
        expect(saved.teamMembers, ['Arif']);
        expect(student.activities.length, initialActivities + 1);
        expect(student.poin, initialPoints);
        expectUploadDenied(work());
        auth.logout();
        auth.login('9999', 'admin123');
        projects.validateProject(saved.id, true);
        expect(saved.isValidated, isTrue);
        expect(
          student.poin,
          initialPoints + ProjectProvider.poinProjectValidated,
        );
      },
    );
  });

  testWidgets('failed upload keeps form open and displays the provider error', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    auth.login('2201', 'password123');
    final count = projects.allProjects.length;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: projects),
        ],
        child: const MaterialApp(home: ShowcaseTab()),
      ),
    );
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(TextField, 'Nama Karya'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nama Karya'),
      'Karya',
    );
    await tester.ensureVisible(find.widgetWithText(TextField, 'Deskripsi'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Deskripsi'),
      'Deskripsi',
    );
    // Simulasi izin berubah ketika formulir masih terbuka.
    student.isActive = false;
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Submit Karya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit Karya'));
    await tester.pumpAndSettle();
    expect(projects.allProjects.length, count);
    expect(find.text('Submit Karya'), findsOneWidget);
    expect(
      find.text('Silakan masuk sebagai siswa terlebih dahulu.'),
      findsOneWidget,
    );
    expect(
      find.text('Karya berhasil disubmit! Menunggu validasi guru.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
