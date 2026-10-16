import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/demo_state.dart';
import '../models/app_state.dart';
import '../storage/app_state_codec.dart';
import '../storage/open_database.dart';
import '../storage/state_store.dart';
import 'memory_repository.dart';

enum SaveStatus { saved, saving, failed }

class LocalRepository extends MemoryRepository {
  final StateStore _store;
  int _revision;
  int _requestedVersion = 0;
  int _savedVersion = 0;
  bool _closed = false;
  Future<void>? _pending;
  Object? _lastError;
  final saveStatus = ValueNotifier(SaveStatus.saved);

  LocalRepository._(super.state, this._store, this._revision);

  static Future<LocalRepository> open({StateStore? store}) async {
    final storage = store ?? await openStateStore();
    try {
      final saved = await storage.read();
      if (saved != null) {
        return LocalRepository._(
          AppStateCodec.decode(saved.data),
          storage,
          saved.revision,
        );
      }
      final AppState initial = createDemoState();
      final revision = await storage.write(
        AppStateCodec.encode(initial),
        expectedRevision: 0,
      );
      return LocalRepository._(initial, storage, revision);
    } catch (_) {
      await storage.close();
      rethrow;
    }
  }

  String get saveErrorMessage => _lastError is StorageConflict
      ? 'Data berubah di jendela lain. Tutup dan buka kembali aplikasi.'
      : 'Perubahan belum tersimpan. Periksa ruang penyimpanan lalu coba lagi.';

  @override
  void markChanged() {
    if (_closed) throw StateError('Repository sudah ditutup.');
    _requestedVersion++;
    _startSave();
  }

  void _startSave() {
    if (_pending != null || _requestedVersion == _savedVersion) return;
    saveStatus.value = SaveStatus.saving;
    // Gabungkan notifikasi dalam aksi yang sama sebelum mengambil snapshot.
    _pending = Future<void>.microtask(_saveLoop).whenComplete(() {
      _pending = null;
      if (_lastError == null && _savedVersion < _requestedVersion) _startSave();
    });
  }

  Future<void> _saveLoop() async {
    try {
      while (_savedVersion < _requestedVersion) {
        final version = _requestedVersion;
        final snapshot = AppStateCodec.encode(state);
        _revision = await _store.write(snapshot, expectedRevision: _revision);
        _savedVersion = version;
      }
      _lastError = null;
      saveStatus.value = SaveStatus.saved;
    } catch (error) {
      _lastError = error;
      saveStatus.value = SaveStatus.failed;
    }
  }

  /// Menunggu semua perubahan, termasuk yang datang saat penulisan berlangsung.
  Future<void> flush() async {
    if (_closed) throw StateError('Repository sudah ditutup.');
    _startSave();
    while (_pending != null) {
      await _pending;
    }
    if (_savedVersion != _requestedVersion) {
      throw _lastError ?? StateError('Data belum tersimpan.');
    }
  }

  Future<void> close() async {
    if (_closed) return;
    try {
      await flush();
    } finally {
      _closed = true;
      await _store.close();
      saveStatus.dispose();
    }
  }
}
