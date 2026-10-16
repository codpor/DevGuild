import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devguild/main.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/repositories/local_repository.dart';
import 'package:devguild/widgets/storage_banner.dart';

import 'support/state_store_stub.dart';

void main() {
  testWidgets('startup failure offers retry instead of starting empty', (
    tester,
  ) async {
    final store = StateStoreStub()..failReads = true;
    var attempts = 0;
    await tester.pumpWidget(
      DevGuildBootstrap(
        openRepository: () {
          attempts++;
          return LocalRepository.open(store: store);
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Data lokal tidak dapat dibuka.'), findsOneWidget);
    expect(find.text('Masuk'), findsNothing);
    expect(store.writes, 0);
    store.failReads = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Data lokal tidak dapat dibuka.'), findsNothing);
    expect(find.text('Masuk'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('saving failure is visible and retry persists changes', (
    tester,
  ) async {
    final store = StateStoreStub();
    final repo = await LocalRepository.open(store: store);
    final auth = AuthProvider(repo);
    await tester.pumpWidget(
      MaterialApp(
        home: StorageBanner(
          repository: repo,
          child: const Scaffold(body: Text('Aplikasi')),
        ),
      ),
    );
    store.failWrites = true;
    auth.register(
      nis: '8888',
      name: 'Siswa Baru',
      kelas: 'XI PPLG 1',
      password: 'test123',
    );
    await expectLater(repo.flush(), throwsStateError);
    await tester.pumpAndSettle();
    expect(find.text(repo.saveErrorMessage), findsOneWidget);
    expect(find.text('Aplikasi'), findsOneWidget);
    store.failWrites = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(repo.saveStatus.value, SaveStatus.saved);
    expect(find.text('Coba lagi'), findsNothing);
    final reopened = await LocalRepository.open(store: store);
    expect(reopened.getUserByNis('8888'), isNotNull);
    await reopened.close();
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
    await repo.close();
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving indicator waits for the actual write', (tester) async {
    final store = StateStoreStub();
    final repo = await LocalRepository.open(store: store);
    final auth = AuthProvider(repo);
    await tester.pumpWidget(
      MaterialApp(
        home: StorageBanner(
          repository: repo,
          child: const Scaffold(body: Text('Aplikasi')),
        ),
      ),
    );
    store.writeGate = Completer<void>();
    auth.login('9999', 'admin123');
    await tester.pump();
    expect(find.text('Menyimpan perubahan...'), findsOneWidget);
    store.writeGate!.complete();
    await repo.flush();
    await tester.pumpAndSettle();
    expect(find.text('Menyimpan perubahan...'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
    await repo.close();
    expect(tester.takeException(), isNull);
  });
}
