import 'package:flutter_test/flutter_test.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';

void main() {
  late MockRepository repo;
  late AuthProvider auth;
  late ProjectProvider projects;

  setUp(() {
    repo = MockRepository();
    auth = AuthProvider(repo);
    projects = ProjectProvider(repo, auth);
  });

  tearDown(() {
    projects.dispose();
    auth.dispose();
  });

  test('like/unlike cycles cannot accumulate author points', () {
    auth.login('2202', 'password123');
    final author = repo.getUserById('u3')!;
    final initialPoints = author.poin;
    final initialLikes = repo.getProjectById('p1')!.likes;
    final wasLiked = auth.currentUser!.likedProjects.contains('p1');
    try {
      if (wasLiked) projects.toggleLikeProject('p1');
      final baseline = author.poin;
      for (var i = 0; i < 3; i++) {
        projects.toggleLikeProject('p1');
        expect(author.poin, baseline + ProjectProvider.poinProjectLiked);
        projects.toggleLikeProject('p1');
        expect(author.poin, baseline);
      }
    } finally {
      author.poin = initialPoints;
      repo.getProjectById('p1')!.likes = initialLikes;
      if (wasLiked) {
        auth.currentUser!.likedProjects.add('p1');
      } else {
        auth.currentUser!.likedProjects.remove('p1');
      }
    }
  });

  test('only teachers can validate projects', () {
    auth.login('2201', 'password123');
    projects.validateProject('p3', true);
    expect(repo.getProjectById('p3')!.isValidated, isFalse);
    auth.logout();
    projects.validateProject('p3', true);
    expect(repo.getProjectById('p3')!.isValidated, isFalse);
  });

  test('approval awards points once and cannot become rejected', () {
    auth.login('9999', 'admin123');
    final author = repo.getUserById('u4')!;
    final initialPoints = author.poin;
    try {
      projects.validateProject('p3', true);
      projects.validateProject('p3', true);
      projects.validateProject('p3', false);
      final project = repo.getProjectById('p3')!;
      expect(author.poin, initialPoints + ProjectProvider.poinProjectValidated);
      expect(project.isValidated, isTrue);
      expect(project.isRejected, isFalse);
    } finally {
      author.poin = initialPoints;
    }
  });

  test('rejection retains feedback and cannot receive approval points', () {
    auth.login('9999', 'admin123');
    final author = repo.getUserById('u4')!;
    final initialPoints = author.poin;
    projects.validateProject('p3', false, feedback: '  Lengkapi demo  ');
    projects.validateProject('p3', true);
    final project = repo.getProjectById('p3')!;
    expect(project.isRejected, isTrue);
    expect(project.isValidated, isFalse);
    expect(project.guruFeedback, 'Lengkapi demo');
    expect(author.poin, initialPoints);
  });

  test('pending projects cannot be liked', () {
    auth.login('2201', 'password123');
    projects.toggleLikeProject('p3');
    expect(repo.getProjectById('p3')!.likes, 0);
    expect(projects.hasLikedProject('p3'), isFalse);
  });

  test('liking own project does not award points', () {
    auth.login('2201', 'password123');
    final user = auth.currentUser!;
    final initialPoints = user.poin;
    final wasLiked = user.likedProjects.contains('p1');
    try {
      projects.toggleLikeProject('p1');
      projects.toggleLikeProject('p1');
      expect(user.poin, initialPoints);
      expect(user.likedProjects.contains('p1'), wasLiked);
    } finally {
      user.poin = initialPoints;
    }
  });
}
