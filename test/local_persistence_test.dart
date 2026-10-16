import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:devguild/models/local_image.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/providers/role_provider.dart';
import 'package:devguild/providers/ticket_provider.dart';
import 'package:devguild/repositories/local_repository.dart';
import 'package:devguild/storage/app_state_codec.dart';
import 'package:devguild/storage/state_store.dart';
import 'package:devguild/utils/result.dart';

import 'support/state_store_stub.dart';

class _Session {
  final LocalRepository repo;
  late final auth = AuthProvider(repo);
  late final projects = ProjectProvider(repo, auth);
  late final tickets = TicketProvider(repo, auth);
  late final roles = RoleProvider(repo, auth);
  _Session(this.repo);

  void dispose() {
    roles.dispose();
    projects.dispose();
    tickets.dispose();
    auth.dispose();
  }
}

void main() {
  late StateStoreStub store;
  late _Session session;
  final photo = LocalImage(
    name: 'photo.png',
    bytes: Uint8List.fromList([1, 2, 3, 4]),
  );

  setUp(() async {
    store = StateStoreStub();
    session = _Session(await LocalRepository.open(store: store));
  });
  tearDown(() async {
    store.failWrites = false;
    store.conflict = false;
    session.dispose();
    await session.repo.close();
  });

  Future<void> restart() async {
    session.dispose();
    await session.repo.close();
    session = _Session(await LocalRepository.open(store: store));
  }

  UserModel register() {
    final result = session.auth.register(
      nis: '8888',
      name: 'Siswa Persisten',
      kelas: 'XI PPLG 1',
      password: 'test123',
    );
    expect(result, isA<Success<UserModel>>());
    return (result as Success<UserModel>).data;
  }

  ProjectModel work(UserModel user) => ProjectModel(
    id: 'persistent-work',
    authorId: user.id,
    authorName: user.name,
    authorKelas: user.kelas,
    title: 'Karya Persisten',
    description: 'Demo',
    category: 'Web',
    linkAkses: 'https://example.com/demo',
    linkGithub: 'https://github.com/example/project',
    teamMembers: [user.name, 'Anggota'],
    teknologi: ['Dart', 'Flutter'],
    screenshot: photo,
    createdAt: DateTime.now(),
  );

  test(
    'accounts, photo, password reset and inactive status survive restart',
    () async {
      final user = register();
      session.auth.updateProfilePhoto(photo, userId: user.id);
      final hash = user.password;
      await restart();
      expect(session.auth.currentUser, isNull);
      expect(session.auth.login('8888', 'test123'), isA<Success<UserModel>>());
      final restored = session.auth.currentUser!;
      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.kelas, user.kelas);
      expect(restored.password, hash);
      expect(restored.profilePhoto!.bytes, photo.bytes);
      expect(restored.profilePhoto!.name, photo.name);
      session.auth.login('9999', 'admin123');
      session.auth.resetStudentPassword(user.id, 'newpass123');
      session.auth.setStudentActive(user.id, false);
      await restart();
      expect(session.repo.getUserById(user.id)!.isActive, isFalse);
      expect(
        session.auth.login('8888', 'newpass123'),
        isA<Failure<UserModel>>(),
      );
      session.auth.login('9999', 'admin123');
      session.auth.setStudentActive(user.id, true);
      await restart();
      expect(session.auth.login('8888', 'test123'), isA<Failure<UserModel>>());
      expect(
        session.auth.login('8888', 'newpass123'),
        isA<Success<UserModel>>(),
      );
      expect(
        session.auth.currentUser!.activities.map((a) => a.title),
        containsAll([
          'Password Direset',
          'Akun Dinonaktifkan',
          'Akun Diaktifkan',
        ]),
      );
      // Pembukaan ulang tidak menambah akun/demo atau membenturkan ID baru.
      final next = session.auth.register(
        nis: '8889',
        name: 'Siswa Kedua',
        kelas: 'XI PPLG 1',
        password: 'test123',
      ) as Success<UserModel>;
      expect(next.data.id, isNot(user.id));
      expect(session.repo.getAllSiswa().length, 7);
    },
  );

  test(
    'review, revision, screenshot, likes, points and badges survive restart',
    () async {
      final user = register();
      expect(
        session.projects.addProject(work(user)),
        isA<Success<ProjectModel>>(),
      );
      await restart();
      final pending = session.repo.getProjectById('persistent-work')!;
      expect(pending.isValidated, isFalse);
      expect(pending.screenshot!.bytes, photo.bytes);
      session.auth.login('9999', 'admin123');
      session.projects.validateProject(
        pending.id,
        false,
        feedback: 'Lengkapi demo',
      );
      await restart();
      expect(
        session.repo.getProjectById(pending.id)!.guruFeedback,
        'Lengkapi demo',
      );
      session.auth.login('8888', 'test123');
      expect(
        session.projects.resubmitProject(
          projectId: pending.id,
          title: 'Karya Revisi',
          description: 'Sudah lengkap',
          category: 'Mobile',
          linkAkses: '',
          linkGithub: pending.linkGithub,
          teamMembers: pending.teamMembers,
          teknologi: pending.teknologi,
        ),
        isA<Success<ProjectModel>>(),
      );
      await restart();
      final revised = session.repo.getProjectById(pending.id)!;
      expect(revised.title, 'Karya Revisi');
      expect(revised.isRejected, isFalse);
      expect(revised.screenshot!.bytes, photo.bytes);
      session.auth.login('9999', 'admin123');
      session.projects.validateProject(pending.id, true);
      session.auth.login('2202', 'password123');
      session.projects.toggleLikeProject(pending.id);
      await restart();
      final approved = session.repo.getProjectById(pending.id)!;
      final author = session.repo.getUserById(user.id)!;
      expect(approved.isValidated, isTrue);
      expect(approved.likes, 1);
      expect(approved.category, 'Mobile');
      expect(approved.linkGithub, pending.linkGithub);
      expect(approved.teamMembers, [user.name, 'Anggota']);
      expect(approved.teknologi, ['Dart', 'Flutter']);
      expect(
        author.poin,
        ProjectProvider.poinProjectValidated + ProjectProvider.poinProjectLiked,
      );
      expect(author.badges, contains('Kreator'));
      expect(
        author.activities.map((a) => a.title),
        containsAll(['Upload Karya', 'Mengirim Revisi Karya']),
      );
      session.auth.login('2202', 'password123');
      expect(session.projects.hasLikedProject(pending.id), isTrue);
      session.projects.toggleLikeProject(pending.id);
      await restart();
      expect(session.repo.getProjectById(pending.id)!.likes, 0);
      expect(
        session.repo.getUserById(user.id)!.poin,
        ProjectProvider.poinProjectValidated,
      );
    },
  );

  test(
    'ticket, reply, accepted answer and contribution points survive restart',
    () async {
      final user = register();
      session.tickets.addTicket(
        TicketModel(
          id: 'persistent-ticket',
          authorId: user.id,
          authorName: user.name,
          authorKelas: user.kelas,
          title: 'Pertanyaan',
          description: 'Masalah kode',
          errorCode: 'ERR_TEST',
          category: 'Dart',
          createdAt: DateTime.now(),
        ),
      );
      session.auth.login('2201', 'password123');
      final initialPoints = session.auth.currentUser!.poin;
      session.tickets.addReply(
        'persistent-ticket',
        ReplyModel(
          id: 'persistent-reply',
          authorId: 'u3',
          authorName: 'Arif Fakhry',
          authorRole: UserRole.mentor,
          content: 'Solusi',
          createdAt: DateTime.now(),
        ),
      );
      await restart();
      final ticket = session.repo.getTicketById('persistent-ticket')!;
      expect(ticket.status, TicketStatus.inProgress);
      expect(ticket.replies.single.content, 'Solusi');
      session.auth.login('8888', 'test123');
      session.tickets.markSolved(ticket.id, 'persistent-reply');
      await restart();
      final solved = session.repo.getTicketById(ticket.id)!;
      expect(solved.status, TicketStatus.solved);
      expect(solved.errorCode, 'ERR_TEST');
      expect(solved.replies.single.isAccepted, isTrue);
      expect(solved.replies.single.authorRole, UserRole.mentor);
      expect(session.repo.getUserById(user.id)!.ticketsCreated, 1);
      expect(
        session.repo.getUserById('u3')!.poin,
        initialPoints +
            TicketProvider.poinReplyTicket +
            TicketProvider.poinAcceptedReply,
      );
      expect(
        session.repo.getUserById('u3')!.badges,
        contains('Pemecah Masalah'),
      );
    },
  );

  test(
    'pending role, approval, mentee switch and rejection survive restart',
    () async {
      session.auth.login('2201', 'password123');
      session.roles.switchToMentee();
      final request = session.roles.submitRoleRequest(
        UserRole.mentor,
      ) as Success<RoleRequestModel>;
      await restart();
      expect(session.roles.pendingRoleRequests.single.id, request.data.id);
      session.auth.login('9999', 'admin123');
      session.roles.approveRoleRequest(request.data.id);
      await restart();
      expect(session.repo.getUserById('u3')!.activeRole, UserRole.mentor);
      expect(
        session.repo.getRoleRequestById(request.data.id)!.status,
        RoleRequestStatus.approved,
      );
      session.auth.login('2201', 'password123');
      session.roles.switchToMentee();
      final second = session.roles.submitRoleRequest(
        UserRole.mentor,
      ) as Success<RoleRequestModel>;
      session.auth.login('9999', 'admin123');
      session.roles.rejectRoleRequest(second.data.id, 'Tinjau kembali');
      await restart();
      expect(session.repo.getUserById('u3')!.activeRole, UserRole.mentee);
      expect(
        session.repo.getRoleRequestById(second.data.id)!.feedback,
        'Tinjau kembali',
      );
      expect(
        session.repo.getRoleRequestById(second.data.id)!.status,
        RoleRequestStatus.rejected,
      );
    },
  );

  test(
    'photo removal, edited title and deleted reply remain removed',
    () async {
      session.auth.login('2202', 'password123');
      session.auth.updateProfilePhoto(photo, userId: 'u4');
      await restart();
      session.auth.login('2202', 'password123');
      session.auth.updateProfilePhoto(null, userId: 'u4');
      session.auth.login('1003', 'password123');
      session.tickets.updateTicketTitle('t3', 'Judul diperbaiki');
      session.tickets.deleteReply('t3', 'r2');
      session.tickets.forceMarkSolved('t3');
      await restart();
      expect(session.repo.getUserById('u4')!.profilePhoto, isNull);
      expect(session.repo.getTicketById('t3')!.title, 'Judul diperbaiki');
      expect(session.repo.getTicketById('t3')!.replies, isEmpty);
      expect(session.repo.getTicketById('t3')!.status, TicketStatus.solved);
    },
  );

  test(
    'autosave includes all changes made during an in-flight write',
    () async {
      store.writeGate = Completer<void>();
      final user = register();
      await Future<void>.delayed(Duration.zero);
      expect(session.repo.saveStatus.value, SaveStatus.saving);
      session.auth.updateProfilePhoto(photo, userId: user.id);
      store.writeGate!.complete();
      await session.repo.flush();
      final saved = AppStateCodec.decode(store.saved!.data);
      expect(
        saved.users.singleWhere((u) => u.id == user.id).profilePhoto!.bytes,
        photo.bytes,
      );
      expect(session.repo.saveStatus.value, SaveStatus.saved);
    },
  );

  test(
    'write failure keeps previous data and retry saves the pending changes',
    () async {
      final original = store.saved;
      store.failWrites = true;
      register();
      await expectLater(session.repo.flush(), throwsStateError);
      expect(session.repo.saveStatus.value, SaveStatus.failed);
      expect(store.saved, same(original));
      expect(session.repo.getUserByNis('8888'), isNotNull);
      store.failWrites = false;
      await session.repo.flush();
      await restart();
      expect(session.repo.getUserByNis('8888'), isNotNull);
    },
  );

  test('automatic saving starts without waiting for app shutdown', () async {
    register();
    await Future<void>.delayed(Duration.zero);
    expect(session.repo.saveStatus.value, SaveStatus.saved);
    expect(
      AppStateCodec.decode(store.saved!.data).users.any((u) => u.nis == '8888'),
      isTrue,
    );
  });

  test(
    'schema mismatch fails to open and preserves the existing snapshot',
    () async {
      final unsupported = StateStoreStub()
        ..saved = StoredState(9, {...store.saved!.data, 'schemaVersion': 999});
      final original = unsupported.saved;
      await expectLater(
        LocalRepository.open(store: unsupported),
        throwsFormatException,
      );
      expect(unsupported.saved, same(original));
      expect(unsupported.writes, 0);
      expect(unsupported.closes, 1);
    },
  );

  test(
    'malformed and duplicate accounts fail to open without reseeding',
    () async {
      for (final data in [
        <String, Object?>{'schemaVersion': 1},
        {
          ...store.saved!.data,
          'users': [
            (store.saved!.data['users'] as List).first,
            (store.saved!.data['users'] as List).first,
          ],
        },
      ]) {
        final invalid = StateStoreStub()..saved = StoredState(1, data);
        await expectLater(
          LocalRepository.open(store: invalid),
          throwsA(anything),
        );
        expect(invalid.saved!.data, same(data));
        expect(invalid.writes, 0);
      }
    },
  );

  test('load failure cannot silently start a fresh demo database', () async {
    final unavailable = StateStoreStub()..failReads = true;
    await expectLater(
      LocalRepository.open(store: unavailable),
      throwsStateError,
    );
    expect(unavailable.writes, 0);
    expect(unavailable.closes, 1);
  });

  test(
    'a stale instance cannot overwrite changes saved by another instance',
    () async {
      final stale = await LocalRepository.open(store: store);
      final staleAuth = AuthProvider(stale);
      register();
      await session.repo.flush();
      staleAuth.login('9999', 'admin123');
      await expectLater(stale.flush(), throwsA(isA<StorageConflict>()));
      expect(stale.saveStatus.value, SaveStatus.failed);
      expect(stale.saveErrorMessage, contains('jendela lain'));
      expect(
        AppStateCodec.decode(store.saved!.data).users
            .any((u) => u.nis == '8888'),
        isTrue,
      );
      staleAuth.dispose();
      await expectLater(stale.close(), throwsA(isA<StorageConflict>()));
    },
  );

  test(
    'real disk database preserves accounts and image bytes after closing',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'devguild-storage-test-',
      );
      final dbPath = path.join(directory.path, 'test.db');
      LocalRepository? disk;
      try {
        disk = await LocalRepository.open(
          store: DatabaseStateStore(
            await databaseFactoryIo.openDatabase(dbPath),
          ),
        );
        final auth = AuthProvider(disk);
        auth.login('2202', 'password123');
        auth.updateProfilePhoto(photo, userId: 'u4');
        auth.dispose();
        await disk.close();
        disk = null;
        expect(await File(dbPath).length(), greaterThan(0));
        disk = await LocalRepository.open(
          store: DatabaseStateStore(
            await databaseFactoryIo.openDatabase(dbPath),
          ),
        );
        expect(disk.getUserById('u4')!.profilePhoto!.bytes, photo.bytes);
        expect(disk.getUserByNis('9999')!.role, 'Guru');
      } finally {
        await disk?.close();
        // Hanya direktori fixture yang baru dibuat di folder temp yang dihapus.
        if (path.equals(
              directory.parent.absolute.path,
              Directory.systemTemp.absolute.path,
            ) &&
            path
                .basename(directory.path)
                .startsWith('devguild-storage-test-')) {
          await directory.delete(recursive: true);
        }
      }
    },
  );
}
