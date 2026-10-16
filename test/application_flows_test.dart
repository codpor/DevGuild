import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devguild/main.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/repositories/local_repository.dart';
import 'package:devguild/screens/siswa/clinic_tab.dart';
import 'package:devguild/screens/siswa/project_revision_screen.dart';

import 'support/state_store_stub.dart';

void main() {
  late StateStoreStub store;
  late LocalRepository repo;

  Future<void> start(WidgetTester tester, {double width = 390}) async {
    await tester.binding.setSurfaceSize(Size(width, 844));
    await tester.pumpWidget(
      DevGuildBootstrap(
        openRepository: () async {
          repo = await LocalRepository.open(store: store);
          return repo;
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String label, String value) async {
    final finder = find.widgetWithText(TextField, label);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
  }

  Future<void> login(WidgetTester tester, String nis, String password) async {
    await fill(tester, 'NIS', nis);
    await fill(tester, 'Password', password);
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String label) => tap(
    tester,
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    ),
  );

  Future<void> logout(WidgetTester tester, {bool teacher = false}) async {
    // Tunggu snackbar hasil aksi selesai agar tombol bawah tidak tertutup.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    if (teacher) {
      await tab(tester, 'Dashboard');
      await tap(tester, find.byIcon(Icons.logout));
    } else {
      await tab(tester, 'Profil');
      await tap(tester, find.widgetWithText(OutlinedButton, 'Keluar'));
    }
    await tap(tester, find.text('Ya, Keluar'));
    expect(find.widgetWithText(ElevatedButton, 'Masuk'), findsOneWidget);
  }

  Finder reviewCard(String title) =>
      find.ancestor(of: find.text(title), matching: find.byType(Card)).first;

  setUp(() => store = StateStoreStub());

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(null);
  }

  testWidgets(
    'student and teacher complete upload, rejection, revision and approval through UI',
    (tester) async {
      addTearDown(() => cleanup(tester));
      await start(tester);
      await login(tester, '2202', 'password123');
      final initialPoints = repo.getUserById('u4')!.poin;
      await tap(tester, find.byIcon(Icons.add_circle_outline));
      await fill(tester, 'Nama Karya', 'Karya Alur UI');
      await fill(tester, 'Deskripsi', 'Versi pertama');
      await tap(tester, find.text('Submit Karya'));
      final project = repo.getAllProjects().singleWhere(
        (p) => p.title == 'Karya Alur UI',
      );
      expect(project.isValidated, isFalse);
      await tab(tester, 'Karya Saya');
      expect(find.text('Karya Alur UI'), findsOneWidget);
      await logout(tester);

      await login(tester, '9999', 'admin123');
      await tab(tester, 'Validasi');
      await tap(
        tester,
        find.descendant(
          of: reviewCard('Karya Alur UI'),
          matching: find.text('Tolak'),
        ),
      );
      await fill(tester, 'Alasan Penolakan *', 'Lengkapi deskripsi demo');
      await tap(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'Tolak'),
        ),
      );
      expect(project.isRejected, isTrue);
      expect(repo.getUserById('u4')!.poin, initialPoints);
      await logout(tester, teacher: true);

      await login(tester, '2202', 'password123');
      await tab(tester, 'Karya Saya');
      expect(find.text('Lengkapi deskripsi demo'), findsOneWidget);
      await tap(tester, find.text('Revisi Karya'));
      await fill(tester, 'Nama Karya', 'Karya Alur UI Revisi');
      await fill(tester, 'Deskripsi', 'Deskripsi demo telah dilengkapi');
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(ProjectRevisionScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tap(tester, find.widgetWithText(ElevatedButton, 'Kirim Revisi'));
      expect(project.isRejected, isFalse);
      expect(project.isValidated, isFalse);
      expect(find.text('Catatan guru sebelumnya'), findsOneWidget);
      await logout(tester);

      await login(tester, '9999', 'admin123');
      await tab(tester, 'Validasi');
      await tap(
        tester,
        find.descendant(
          of: reviewCard('Karya Alur UI Revisi'),
          matching: find.text('Setujui'),
        ),
      );
      expect(project.isValidated, isTrue);
      expect(repo.getUserById('u4')!.poin, initialPoints + 50);
      await logout(tester, teacher: true);

      // Tutup seluruh aplikasi dan buka repository baru dari media penyimpanan sama.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await start(tester);
      await login(tester, '2202', 'password123');
      expect(find.text('Karya Alur UI Revisi'), findsOneWidget);
      await tab(tester, 'Karya Saya');
      await tap(tester, find.widgetWithText(ChoiceChip, 'Disetujui'));
      expect(find.text('Karya Alur UI Revisi'), findsOneWidget);
      expect(find.text('Revisi Karya'), findsNothing);
      expect(repo.getUserById('u4')!.poin, initialPoints + 50);
    },
  );

  testWidgets(
    'student and teacher complete ticket, reply and accepted answer through UI',
    (tester) async {
      addTearDown(() => cleanup(tester));
      await start(tester);
      await login(tester, '2202', 'password123');
      final initialPoints = repo.getUserById('u4')!.poin;
      final teacherPoints = repo.getUserById('u1')!.poin;
      await tab(tester, 'Klinik');
      await tap(tester, find.text('Buat Tiket'));
      await fill(tester, 'Judul Error', 'Tiket Alur UI');
      await fill(
        tester,
        'Deskripsi Masalah',
        'Bagaimana mengatasi error koneksi?',
      );
      await tap(tester, find.text('Kirim Tiket'));
      final ticket = repo.getAllTickets().singleWhere(
        (t) => t.title == 'Tiket Alur UI',
      );
      expect(ticket.status, TicketStatus.open);
      expect(repo.getUserById('u4')!.poin, initialPoints + 5);
      await logout(tester);

      await login(tester, '9999', 'admin123');
      await tab(tester, 'Klinik');
      await tap(tester, find.text('Tiket Alur UI'));
      final replyField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Tulis balasan...',
      );
      await tester.enterText(
        replyField,
        'Periksa konfigurasi dan jalankan ulang koneksi.',
      );
      await tap(tester, find.byIcon(Icons.send));
      expect(ticket.status, TicketStatus.inProgress);
      expect(
        ticket.replies.single.content,
        'Periksa konfigurasi dan jalankan ulang koneksi.',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await logout(tester, teacher: true);

      await login(tester, '2202', 'password123');
      await tab(tester, 'Klinik');
      await tap(tester, find.text('Tiket Alur UI'));
      await tap(tester, find.text('Tandai Solved'));
      expect(ticket.status, TicketStatus.solved);
      expect(ticket.replies.single.isAccepted, isTrue);
      expect(find.text('Tandai Solved'), findsNothing);
      expect(repo.getUserById('u1')!.poin, teacherPoints + 35);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await start(tester);
      await login(tester, '2202', 'password123');
      await tab(tester, 'Klinik');
      await tap(tester, find.widgetWithText(ChoiceChip, 'Solved'));
      await tap(tester, find.text('Tiket Alur UI'));
      expect(repo.getTicketById(ticket.id)!.replies.single.isAccepted, isTrue);
      expect(find.byIcon(Icons.send), findsNothing);
    },
  );

  testWidgets(
    'invalid upload shows its error inside the form and can be corrected',
    (tester) async {
      addTearDown(() => cleanup(tester));
      await start(tester, width: 320);
      await login(tester, '2202', 'password123');
      final count = repo.getAllProjects().length;
      await tap(tester, find.byIcon(Icons.add_circle_outline));
      await fill(tester, 'Nama Karya', 'Karya URL');
      await fill(tester, 'Deskripsi', 'Deskripsi karya');
      await fill(tester, 'Link Akses / Demo (opsional)', 'bukan-url');
      await tap(tester, find.text('Submit Karya'));
      expect(repo.getAllProjects().length, count);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Masukkan URL http:// atau https:// yang valid'),
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, 'Nama Karya'), findsOneWidget);
      await fill(tester, 'Link Akses / Demo (opsional)', 'https://example.com');
      await tap(tester, find.text('Submit Karya'));
      expect(repo.getAllProjects().length, count + 1);
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'whitespace ticket is rejected visibly without false success or points',
    (tester) async {
      addTearDown(() => cleanup(tester));
      await start(tester, width: 320);
      await login(tester, '2202', 'password123');
      final count = repo.getAllTickets().length;
      final points = repo.getUserById('u4')!.poin;
      await tab(tester, 'Klinik');
      await tap(tester, find.text('Buat Tiket'));
      await fill(tester, 'Judul Error', '   ');
      await fill(tester, 'Deskripsi Masalah', 'Deskripsi tetap tersedia');
      await tap(tester, find.text('Kirim Tiket'));
      expect(repo.getAllTickets().length, count);
      expect(repo.getUserById('u4')!.poin, points);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Judul tiket wajib diisi'),
        ),
        findsOneWidget,
      );
      expect(find.text('Tiket berhasil dibuat!'), findsNothing);
      await fill(tester, 'Judul Error', 'Tiket Diperbaiki');
      await tap(tester, find.text('Kirim Tiket'));
      final saved = repo.getAllTickets().singleWhere(
        (t) => t.title == 'Tiket Diperbaiki',
      );
      expect(saved.description, 'Deskripsi tetap tersedia');
      expect(repo.getUserById('u4')!.poin, points + 5);
    },
  );

  testWidgets('failed reply keeps the draft instead of clearing it', (
    tester,
  ) async {
    addTearDown(() => cleanup(tester));
    await start(tester);
    await login(tester, '9999', 'admin123');
    await tab(tester, 'Klinik');
    await tap(tester, find.text('Tampilan website tidak rapi di mobile'));
    final field = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Tulis balasan...',
    );
    await tester.enterText(field, 'Draft balasan tetap ada');
    // Tiket ditutup setelah formulir dibuka, sebelum balasan dikirim.
    final ticket = repo.getTicketById('t2')!..status = TicketStatus.solved;
    final points = repo.getUserById('u1')!.poin;
    await tap(tester, find.byIcon(Icons.send));
    expect(ticket.replies, isEmpty);
    expect(repo.getUserById('u1')!.poin, points);
    expect(
      tester.widget<TextField>(field).controller!.text,
      'Draft balasan tetap ada',
    );
    expect(
      find.text('Tiket sudah selesai atau balasan sudah dikirim.'),
      findsOneWidget,
    );
  });

  testWidgets('student screens and solved teacher reply fit a 320px display', (
    tester,
  ) async {
    addTearDown(() => cleanup(tester));
    await start(tester, width: 320);
    await login(tester, '2202', 'password123');
    for (final label in ['Karya Saya', 'Klinik', 'Peringkat', 'Profil']) {
      await tab(tester, label);
    }
    await tab(tester, 'Klinik');
    await tap(tester, find.text('Error koneksi database MySQL di PHP'));
    expect(find.byType(TicketDetailScreen), findsOneWidget);
  });
}
