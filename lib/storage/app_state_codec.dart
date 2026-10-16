import 'dart:typed_data';

import 'package:sembast/blob.dart';

import '../models/app_state.dart';
import '../models/local_image.dart';
import '../models/models.dart';

/// Format berversi. Data yang tidak valid tidak pernah diganti dengan data demo.
class AppStateCodec {
  static const schemaVersion = 1;

  static Map<String, Object?> encode(AppState state) => {
    'schemaVersion': schemaVersion,
    'users': state.users
        .map(
          (u) => <String, Object?>{
            'id': u.id,
            'nis': u.nis,
            'password': u.password,
            'name': u.name,
            'kelas': u.kelas,
            'role': u.role,
            'isActive': u.isActive,
            'activeRole': u.activeRole.name,
            'poin': u.poin,
            'ticketsCreated': u.ticketsCreated,
            'ticketsAnswered': u.ticketsAnswered,
            'profilePhoto': _image(u.profilePhoto),
            'badges': List.of(u.badges),
            'likedProjects': u.likedProjects.toList(),
            'activities': u.activities
                .map(
                  (a) => <String, Object?>{
                    'title': a.title,
                    'description': a.description,
                    'time': a.time.toIso8601String(),
                    'icon': a.icon,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'tickets': state.tickets
        .map(
          (t) => <String, Object?>{
            'id': t.id,
            'authorId': t.authorId,
            'authorName': t.authorName,
            'authorKelas': t.authorKelas,
            'title': t.title,
            'description': t.description,
            'errorCode': t.errorCode,
            'category': t.category,
            'status': t.status.name,
            'createdAt': t.createdAt.toIso8601String(),
            'replies': t.replies
                .map(
                  (r) => <String, Object?>{
                    'id': r.id,
                    'authorId': r.authorId,
                    'authorName': r.authorName,
                    'authorRole': r.authorRole.name,
                    'content': r.content,
                    'createdAt': r.createdAt.toIso8601String(),
                    'isAccepted': r.isAccepted,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'projects': state.projects
        .map(
          (p) => <String, Object?>{
            'id': p.id,
            'authorId': p.authorId,
            'authorName': p.authorName,
            'authorKelas': p.authorKelas,
            'title': p.title,
            'description': p.description,
            'category': p.category,
            'linkAkses': p.linkAkses,
            'linkGithub': p.linkGithub,
            'teamMembers': List.of(p.teamMembers),
            'teknologi': List.of(p.teknologi),
            'screenshot': _image(p.screenshot),
            'isValidated': p.isValidated,
            'isRejected': p.isRejected,
            'guruFeedback': p.guruFeedback,
            'createdAt': p.createdAt.toIso8601String(),
            'likes': p.likes,
          },
        )
        .toList(),
    'roleRequests': state.roleRequests
        .map(
          (r) => <String, Object?>{
            'id': r.id,
            'userId': r.userId,
            'userName': r.userName,
            'userKelas': r.userKelas,
            'requestedRole': r.requestedRole.name,
            'createdAt': r.createdAt.toIso8601String(),
            'status': r.status.name,
            'feedback': r.feedback,
            'userPoin': r.userPoin,
            'userProjectCount': r.userProjectCount,
            'userTicketsAnswered': r.userTicketsAnswered,
          },
        )
        .toList(),
  };

  static AppState decode(Map<String, Object?> data) {
    if (data['schemaVersion'] != schemaVersion) {
      throw const FormatException('Versi database tidak didukung.');
    }
    final state = AppState(
      users: _records(data['users'])
          .map(
            (u) => UserModel(
              id: u['id'] as String,
              nis: u['nis'] as String,
              password: u['password'] as String,
              name: u['name'] as String,
              kelas: u['kelas'] as String,
              role: u['role'] as String,
              isActive: u['isActive'] as bool,
              activeRole: UserRole.values.byName(u['activeRole'] as String),
              poin: u['poin'] as int,
              ticketsCreated: u['ticketsCreated'] as int,
              ticketsAnswered: u['ticketsAnswered'] as int,
              profilePhoto: _readImage(u['profilePhoto']),
              badges: List<String>.from(u['badges'] as List),
              likedProjects: Set<String>.from(u['likedProjects'] as List),
              activities: _records(u['activities'])
                  .map(
                    (a) => ActivityItem(
                      title: a['title'] as String,
                      description: a['description'] as String,
                      time: DateTime.parse(a['time'] as String),
                      icon: a['icon'] as String,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      tickets: _records(data['tickets'])
          .map(
            (t) => TicketModel(
              id: t['id'] as String,
              authorId: t['authorId'] as String,
              authorName: t['authorName'] as String,
              authorKelas: t['authorKelas'] as String,
              title: t['title'] as String,
              description: t['description'] as String,
              errorCode: t['errorCode'] as String,
              category: t['category'] as String,
              status: TicketStatus.values.byName(t['status'] as String),
              createdAt: DateTime.parse(t['createdAt'] as String),
              replies: _records(t['replies'])
                  .map(
                    (r) => ReplyModel(
                      id: r['id'] as String,
                      authorId: r['authorId'] as String,
                      authorName: r['authorName'] as String,
                      authorRole: UserRole.values.byName(
                        r['authorRole'] as String,
                      ),
                      content: r['content'] as String,
                      createdAt: DateTime.parse(r['createdAt'] as String),
                      isAccepted: r['isAccepted'] as bool,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      projects: _records(data['projects'])
          .map(
            (p) => ProjectModel(
              id: p['id'] as String,
              authorId: p['authorId'] as String,
              authorName: p['authorName'] as String,
              authorKelas: p['authorKelas'] as String,
              title: p['title'] as String,
              description: p['description'] as String,
              category: p['category'] as String,
              linkAkses: p['linkAkses'] as String,
              linkGithub: p['linkGithub'] as String,
              teamMembers: List<String>.from(p['teamMembers'] as List),
              teknologi: List<String>.from(p['teknologi'] as List),
              screenshot: _readImage(p['screenshot']),
              isValidated: p['isValidated'] as bool,
              isRejected: p['isRejected'] as bool,
              guruFeedback: p['guruFeedback'] as String,
              createdAt: DateTime.parse(p['createdAt'] as String),
              likes: p['likes'] as int,
            ),
          )
          .toList(),
      roleRequests: _records(data['roleRequests'])
          .map(
            (r) => RoleRequestModel(
              id: r['id'] as String,
              userId: r['userId'] as String,
              userName: r['userName'] as String,
              userKelas: r['userKelas'] as String,
              requestedRole: UserRole.values.byName(
                r['requestedRole'] as String,
              ),
              createdAt: DateTime.parse(r['createdAt'] as String),
              status: RoleRequestStatus.values.byName(r['status'] as String),
              feedback: r['feedback'] as String,
              userPoin: r['userPoin'] as int,
              userProjectCount: r['userProjectCount'] as int,
              userTicketsAnswered: r['userTicketsAnswered'] as int,
            ),
          )
          .toList(),
    );
    _unique(state.users.map((u) => u.id));
    _unique(state.users.map((u) => u.nis));
    _unique(state.tickets.map((t) => t.id));
    _unique(state.projects.map((p) => p.id));
    _unique(state.roleRequests.map((r) => r.id));
    if (state.users.any((u) => u.role != 'Guru' && u.role != 'Siswa')) {
      throw const FormatException('Jenis akun tidak valid.');
    }
    return state;
  }

  static List<Map<String, Object?>> _records(Object? value) => (value as List)
      .map((item) => Map<String, Object?>.from(item as Map))
      .toList();

  static Map<String, Object?>? _image(LocalImage? image) => image == null
      ? null
      : {'name': image.name, 'bytes': Blob(Uint8List.fromList(image.bytes))};

  static LocalImage? _readImage(Object? value) {
    if (value == null) return null;
    final image = Map<String, Object?>.from(value as Map);
    return LocalImage(
      name: image['name'] as String,
      bytes: (image['bytes'] as Blob).bytes,
    );
  }

  static void _unique(Iterable<String> values) {
    final seen = <String>{};
    for (final value in values) {
      if (value.isEmpty || !seen.add(value)) {
        throw const FormatException(
          'ID atau NIS kosong/duplikat dalam database.',
        );
      }
    }
  }
}
