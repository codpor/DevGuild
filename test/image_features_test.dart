import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/models/local_image.dart';
import 'package:devguild/models/models.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';
import 'package:devguild/screens/siswa/profile_photo_screen.dart';
import 'package:devguild/screens/siswa/showcase_tab.dart';
import 'package:devguild/services/image_picker_service.dart';
import 'package:devguild/utils/result.dart';
import 'package:devguild/widgets/image_upload_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Uint8List png;
  late LocalImage sample;
  setUpAll(() async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const Color(0xFF6C63FF), ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(8, 8);
    final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    png = Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    image.dispose();
    picture.dispose();
    sample = LocalImage(name: 'screenshot.png', bytes: png);
  });

  test('valid PNG can be decoded and normalized', () async {
    final image = await ImagePickerService.fromBytes(png, 'valid.png');
    expect(image.name, 'valid.png');
    expect(image.bytes, isNotEmpty);
    expect(image.bytes.length, lessThanOrEqualTo(ImagePickerService.maxBytes));
  });

  test('non-image input is rejected', () async {
    await expectLater(
      ImagePickerService.fromBytes(Uint8List.fromList([1, 2, 3]), 'fake.png'),
      throwsA(isA<ImageSelectionException>()),
    );
  });

  test('truncated PNG is rejected', () async {
    await expectLater(
      ImagePickerService.fromBytes(png.sublist(0, 8), 'broken.png'),
      throwsA(isA<ImageSelectionException>()),
    );
  });

  test('oversized and empty images are rejected', () async {
    await expectLater(
      ImagePickerService.fromBytes(
        Uint8List(ImagePickerService.maxBytes + 1),
        'large.png',
      ),
      throwsA(isA<ImageSelectionException>()),
    );
    await expectLater(
      ImagePickerService.fromBytes(Uint8List(0), 'empty.png'),
      throwsA(isA<ImageSelectionException>()),
    );
  });

  testWidgets('image field previews, replaces and removes a selection', (
    tester,
  ) async {
    LocalImage? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ImageUploadField(
              value: selected,
              label: 'Screenshot',
              pickImage: () async => sample,
              onChanged: (image) => setState(() => selected = image),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pilih Gambar'));
    await tester.pumpAndSettle();
    expect(selected, same(sample));
    expect(find.text('screenshot.png'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.text('Ganti Gambar'));
    await tester.pumpAndSettle();
    expect(selected, same(sample));
    await tester.tap(find.text('Hapus Gambar'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling the picker preserves the previous image', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUploadField(
            value: sample,
            label: 'Foto',
            pickImage: () async => null,
            onChanged: (_) => changes++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ganti Gambar'));
    await tester.pumpAndSettle();
    expect(changes, 0);
    expect(find.text('screenshot.png'), findsOneWidget);
  });

  testWidgets('picker failures show an error without changing the image', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUploadField(
            value: sample,
            label: 'Foto',
            pickImage: () async =>
                throw const ImageSelectionException('Gambar rusak'),
            onChanged: (_) => changes++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ganti Gambar'));
    await tester.pumpAndSettle();
    expect(find.text('Gambar rusak'), findsOneWidget);
    expect(changes, 0);
  });

  testWidgets('a pending picker cannot update a disposed field', (
    tester,
  ) async {
    final pending = Completer<LocalImage?>();
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUploadField(
            value: null,
            label: 'Foto',
            pickImage: () => pending.future,
            onChanged: (_) => changes++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pilih Gambar'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete(sample);
    await tester.pump();
    expect(changes, 0);
    expect(tester.takeException(), isNull);
  });

  group('image data flows', () {
    late MockRepository repo;
    late AuthProvider auth;
    late ProjectProvider projects;
    late Map<UserModel, LocalImage?> photos;
    late Map<UserModel, List<ActivityItem>> activities;
    setUp(() {
      repo = MockRepository();
      auth = AuthProvider(repo);
      projects = ProjectProvider(repo, auth);
      photos = {for (final user in repo.getAllSiswa()) user: user.profilePhoto};
      activities = {
        for (final user in repo.getAllSiswa()) user: [...user.activities],
      };
    });
    tearDown(() {
      for (final entry in photos.entries) {
        entry.key.profilePhoto = entry.value;
        entry.key.activities
          ..clear()
          ..addAll(activities[entry.key]!);
      }
      projects.dispose();
      auth.dispose();
    });
    Widget app(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: projects),
      ],
      child: MaterialApp(home: child),
    );
    Result<ProjectModel> revise({bool update = false, LocalImage? image}) =>
        projects.resubmitProject(
          projectId: 'p3',
          title: 'Portofolio Revisi',
          description: 'Demo diperbaiki',
          category: 'Web',
          linkAkses: '',
          linkGithub: '',
          teamMembers: [],
          teknologi: [],
          screenshot: image,
          updateScreenshot: update,
        );

    test('profile photos can only be changed by the signed-in owner', () {
      expect(
        auth.updateProfilePhoto(sample, userId: 'u4'),
        isA<Failure<UserModel>>(),
      );
      auth.login('2202', 'password123');
      expect(
        auth.updateProfilePhoto(sample, userId: 'u3'),
        isA<Failure<UserModel>>(),
      );
      expect(
        auth.updateProfilePhoto(sample, userId: 'u4'),
        isA<Success<UserModel>>(),
      );
      expect(repo.getUserById('u4')!.profilePhoto, same(sample));
      expect(
        auth.updateProfilePhoto(null, userId: 'u4'),
        isA<Success<UserModel>>(),
      );
      expect(repo.getUserById('u4')!.profilePhoto, isNull);
    });

    test(
      'project revision preserves screenshots unless explicitly changed',
      () {
        auth.login('2202', 'password123');
        final project = repo.getProjectById('p3')
          ..screenshot = sample
          ..isRejected = true;
        expect(revise(), isA<Success<ProjectModel>>());
        expect(project.screenshot, same(sample));
        project.isRejected = true;
        final replacement = LocalImage(name: 'replacement.png', bytes: png);
        expect(
          revise(update: true, image: replacement),
          isA<Success<ProjectModel>>(),
        );
        expect(project.screenshot, same(replacement));
        project.isRejected = true;
        expect(revise(update: true), isA<Success<ProjectModel>>());
        expect(project.screenshot, isNull);
      },
    );

    testWidgets('profile editor saves a chosen image after confirmation', (
      tester,
    ) async {
      auth.login('2202', 'password123');
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ProfilePhotoScreen(
                      userId: 'u4',
                      pickImage: () async => sample,
                    ),
                  ),
                ),
                child: const Text('Edit Foto'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit Foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih Gambar'));
      await tester.pumpAndSettle();
      expect(auth.currentUser!.profilePhoto, isNull);
      await tester.tap(find.text('Simpan Foto'));
      await tester.pumpAndSettle();
      expect(auth.currentUser!.profilePhoto, same(sample));
      expect(find.byType(ProfilePhotoScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('new project submission retains the selected screenshot', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      auth.login('2202', 'password123');
      await tester.pumpWidget(app(ShowcaseTab(pickImage: () async => sample)));
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih Gambar'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(TextField, 'Nama Karya'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nama Karya'),
        'Karya Bergambar',
      );
      await tester.ensureVisible(find.widgetWithText(TextField, 'Deskripsi'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Deskripsi'),
        'Contoh screenshot',
      );
      await tester.ensureVisible(find.text('Submit Karya'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit Karya'));
      await tester.pumpAndSettle();
      final project = projects.myProjects.firstWhere(
        (p) => p.title == 'Karya Bergambar',
      );
      expect(project.screenshot, same(sample));
      expect(project.isValidated, isFalse);
      expect(find.byType(ImageUploadField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
