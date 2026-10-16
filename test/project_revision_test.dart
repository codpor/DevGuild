import 'package:flutter_test/flutter_test.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/utils/result.dart';

void main() {
  late MockRepository repo;
  late AuthProvider auth;
  late ProjectProvider projects;
  late Map<UserModel, int> points;
  late Map<UserModel, List<ActivityItem>> activities;

  setUp(() {
    repo = MockRepository();
    auth = AuthProvider(repo);
    projects = ProjectProvider(repo, auth);
    points = {for (final user in repo.getAllSiswa()) user: user.poin};
    activities = {
      for (final user in repo.getAllSiswa()) user: [...user.activities],
    };
  });
  tearDown(() {
    for (final entry in points.entries) {
      entry.key.poin = entry.value;
      entry.key.activities
        ..clear()
        ..addAll(activities[entry.key]!);
    }
    projects.dispose();
    auth.dispose();
  });

  Result<ProjectModel> revise({
    String id = 'p3',
    String title = 'Portofolio Revisi',
    String description = 'Deskripsi diperbaiki',
    String category = 'Web',
    String demo = 'https://example.com/demo',
    String github = '',
  }) => projects.resubmitProject(
    projectId: id,
    title: title,
    description: description,
    category: category,
    linkAkses: demo,
    linkGithub: github,
    teamMembers: [' Siti Rahayu ', '', 'Siti Rahayu'],
    teknologi: [' HTML ', 'CSS', '', 'HTML'],
  );

  void reject() {
    auth.login('9999', 'admin123');
    projects.validateProject(
      'p3',
      false,
      feedback: 'Lengkapi demo dan deskripsi',
    );
    auth.logout();
  }

  test('my projects are limited to the signed-in student', () {
    expect(projects.myProjects, isEmpty);
    auth.login('9999', 'admin123');
    expect(projects.myProjects, isEmpty);
    auth.logout();
    auth.login('2202', 'password123');
    expect(projects.myProjects.map((project) => project.id), ['p3']);
    auth.logout();
    auth.login('2201', 'password123');
    expect(projects.myProjects.map((project) => project.id), ['p1']);
  });

  test(
    'revision retains identity, feedback and points and returns to review',
    () {
      reject();
      auth.login('2202', 'password123');
      final project = repo.getProjectById('p3')!;
      final createdAt = project.createdAt;
      final initialPoints = auth.currentUser!.poin;
      final count = projects.allProjects.length;
      expect(
        revise(title: '  Portofolio Revisi  '),
        isA<Success<ProjectModel>>(),
      );
      expect(repo.getProjectById('p3'), same(project));
      expect(project.title, 'Portofolio Revisi');
      expect(project.authorId, 'u4');
      expect(project.createdAt, createdAt);
      expect(project.isRejected, isFalse);
      expect(project.isValidated, isFalse);
      expect(project.guruFeedback, 'Lengkapi demo dan deskripsi');
      expect(project.teamMembers, ['Siti Rahayu']);
      expect(project.teknologi, ['HTML', 'CSS']);
      expect(auth.currentUser!.poin, initialPoints);
      expect(projects.allProjects.length, count);
      expect(projects.pendingProjects, contains(project));
      expect(auth.currentUser!.activities.first.title, 'Mengirim Revisi Karya');
    },
  );

  test('another student cannot revise a rejected project', () {
    reject();
    auth.login('2201', 'password123');
    expect(revise(), isA<Failure<ProjectModel>>());
    expect(repo.getProjectById('p3')!.isRejected, isTrue);
    expect(repo.getProjectById('p3')!.title, 'Website Portofolio Personal');
  });

  test('anonymous users and teachers cannot submit revisions', () {
    reject();
    expect(revise(), isA<Failure<ProjectModel>>());
    auth.login('9999', 'admin123');
    expect(revise(), isA<Failure<ProjectModel>>());
    expect(repo.getProjectById('p3')!.isRejected, isTrue);
  });

  test('pending and approved projects cannot be revised', () {
    auth.login('2202', 'password123');
    expect(revise(), isA<Failure<ProjectModel>>());
    auth.logout();
    auth.login('2201', 'password123');
    expect(revise(id: 'p1'), isA<Failure<ProjectModel>>());
  });

  test('missing project returns a failure instead of throwing', () {
    auth.login('2202', 'password123');
    expect(revise(id: 'missing'), isA<Failure<ProjectModel>>());
  });

  test('invalid input leaves rejected project unchanged', () {
    reject();
    auth.login('2202', 'password123');
    for (final result in [
      revise(title: '   '),
      revise(description: '   '),
      revise(category: 'Tidak dikenal'),
      revise(demo: 'javascript:alert(1)'),
      revise(demo: 'https://'),
      revise(github: 'https://user:password@example.com'),
      revise(demo: 'https://example.com/bad path'),
    ]) {
      expect(result, isA<Failure<ProjectModel>>());
    }
    expect(repo.getProjectById('p3')!.isRejected, isTrue);
    expect(repo.getProjectById('p3')!.title, 'Website Portofolio Personal');
  });

  test('revision cannot be sent twice before review', () {
    reject();
    auth.login('2202', 'password123');
    expect(revise(), isA<Success<ProjectModel>>());
    expect(revise(title: 'Second revision'), isA<Failure<ProjectModel>>());
    expect(repo.getProjectById('p3')!.title, 'Portofolio Revisi');
  });

  test('teacher approves revised project with a single points award', () {
    reject();
    auth.login('2202', 'password123');
    final initialPoints = auth.currentUser!.poin;
    revise();
    auth.logout();
    auth.login('9999', 'admin123');
    projects.validateProject('p3', true);
    projects.validateProject('p3', true);
    expect(repo.getProjectById('p3')!.isValidated, isTrue);
    expect(repo.getProjectById('p3')!.isRejected, isFalse);
    expect(
      repo.getUserById('u4')!.poin,
      initialPoints + ProjectProvider.poinProjectValidated,
    );
    expect(
      projects.validatedProjects.map((project) => project.id),
      contains('p3'),
    );
  });
}
