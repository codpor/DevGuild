import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/constants/app_strings.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/screens/register_screen.dart';
import 'package:devguild/utils/password_hasher.dart';
import 'package:devguild/utils/result.dart';

class _CustomIdRepository extends MockRepository {
  @override
  String generateUserId() => 'custom-student-id';
}

void main() {
  late MockRepository repo;
  late AuthProvider auth;

  setUp(() {
    repo = MockRepository();
    auth = AuthProvider(repo);
  });
  tearDown(() => auth.dispose());

  Result<UserModel> register({
    String nis = '8888',
    String name = 'Siswa Baru',
    String kelas = 'XI PPLG 1',
    String password = 'test123',
  }) => auth.register(nis: nis, name: name, kelas: kelas, password: password);

  final invalidInputs = <String, Map<String, String>>{
    'empty NIS': {'nis': ''},
    'whitespace NIS': {'nis': '    '},
    'short NIS': {'nis': '123'},
    'letters in NIS': {'nis': 'ABCD'},
    'mixed NIS': {'nis': '12a4'},
    'negative NIS': {'nis': '-1234'},
    'empty name': {'name': ''},
    'whitespace name': {'name': '    '},
    'short name': {'name': ' Ab '},
    'empty password': {'password': ''},
    'short password': {'password': '12345'},
    'whitespace password': {'password': '      '},
    'empty class': {'kelas': ''},
    'whitespace class': {'kelas': '    '},
    'unknown class': {'kelas': 'Kelas Palsu'},
  };

  for (final entry in invalidInputs.entries) {
    test('${entry.key} is rejected without changing accounts or session', () {
      auth.login('2202', 'password123');
      final session = auth.currentUser;
      final count = repo.getAllSiswa().length;
      var changes = 0;
      auth.addListener(() => changes++);
      final result = register(
        nis: entry.value['nis'] ?? '8888',
        name: entry.value['name'] ?? 'Siswa Baru',
        kelas: entry.value['kelas'] ?? 'XI PPLG 1',
        password: entry.value['password'] ?? 'test123',
      );
      expect(result, isA<Failure<UserModel>>());
      expect((result as Failure<UserModel>).code, 'INVALID_INPUT');
      expect(result.message, isNotEmpty);
      expect(repo.getAllSiswa().length, count);
      expect(auth.currentUser, same(session));
      expect(changes, 0);
    });
  }

  test(
    'valid registration trims identity, hashes exact password and logs in',
    () {
      final result = register(
        nis: '  0888  ',
        name: '  Siswa Baru  ',
        kelas: '  XI PPLG 1  ',
        password: '  test123  ',
      );
      expect(result, isA<Success<UserModel>>());
      final user = (result as Success<UserModel>).data;
      expect(user.nis, '0888');
      expect(user.name, 'Siswa Baru');
      expect(user.kelas, 'XI PPLG 1');
      expect(user.role, 'Siswa');
      expect(user.activeRole, UserRole.mentee);
      expect(user.password, isNot('  test123  '));
      expect(PasswordHasher.verify('  test123  ', user.password), isTrue);
      expect(PasswordHasher.verify('test123', user.password), isFalse);
      expect(auth.currentUser, same(user));
      auth.logout();
      expect(auth.login('0888', '  test123  '), isA<Success<UserModel>>());
    },
  );

  for (final active in [true, false]) {
    test(
      'duplicate NIS with surrounding spaces is blocked for active=$active',
      () {
        final original = repo.getUserByNis('2202')!..isActive = active;
        final count = repo.getAllSiswa().length;
        final password = original.password;
        final result = register(nis: ' 2202 ');
        expect(result, isA<Failure<UserModel>>());
        expect((result as Failure<UserModel>).code, 'NIS_EXISTS');
        expect(repo.getAllSiswa().length, count);
        expect(repo.getUserByNis('2202'), same(original));
        expect(original.password, password);
        expect(auth.currentUser, isNull);
      },
    );
  }

  test('generated IDs remain unique when existing IDs have gaps', () {
    final existing = UserModel(
      id: 'u8',
      nis: '8000',
      name: 'Existing',
      kelas: 'X PPLG 1',
      role: 'Siswa',
    );
    repo.addUser(existing);
    final first = (register(nis: '8888') as Success<UserModel>).data;
    final second = (register(nis: '8889') as Success<UserModel>).data;
    expect(first.id, isNot(second.id));
    expect(first.id, isNot('u8'));
    expect(second.id, isNot('u8'));
    expect(repo.getUserById('u8'), same(existing));
    final ids = repo.getAllSiswa().map((u) => u.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(repo.getUserById('u1')!.role, 'Guru');
  });

  test(
    'registration uses ID generation declared in the repository contract',
    () {
      final customRepo = _CustomIdRepository();
      final session = AuthProvider(customRepo);
      addTearDown(session.dispose);
      final result = session.register(
        nis: '8888',
        name: 'Siswa Baru',
        kelas: 'XI PPLG 1',
        password: 'test123',
      );
      expect(result, isA<Success<UserModel>>());
      expect(session.currentUser!.id, 'custom-student-id');
      expect(
        customRepo.getUserById('custom-student-id'),
        same(session.currentUser),
      );
    },
  );

  testWidgets('registration form reports whitespace passwords', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    Future<void> fill(String label, String text) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, text);
    }

    await fill(AppStrings.nisLabel, '8888');
    await fill(AppStrings.nameLabel, 'Siswa Baru');
    await fill(AppStrings.passwordLabel, '      ');
    await fill(AppStrings.confirmPasswordLabel, '      ');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(ElevatedButton, AppStrings.registerNow);
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(
      find.text('Password tidak boleh hanya berisi spasi.'),
      findsOneWidget,
    );
    expect(repo.getUserByNis('8888'), isNull);
    expect(auth.currentUser, isNull);
    expect(tester.takeException(), isNull);
  });
}
