import 'dart:async';

import 'package:devguild/storage/state_store.dart';

/// Meniru media penyimpanan yang tetap ada ketika repository dibuat ulang.
class StateStoreStub implements StateStore {
  StoredState? saved;
  bool failWrites = false;
  bool failReads = false;
  bool conflict = false;
  Completer<void>? writeGate;
  int writes = 0;
  int closes = 0;

  @override
  Future<StoredState?> read() async {
    if (failReads) throw StateError('Storage unavailable');
    return saved;
  }

  @override
  Future<int> write(
    Map<String, Object?> data, {
    required int expectedRevision,
  }) async {
    await writeGate?.future;
    if (failWrites) throw StateError('Disk full');
    if (conflict || (saved?.revision ?? 0) != expectedRevision) {
      throw const StorageConflict();
    }
    writes++;
    final revision = expectedRevision + 1;
    saved = StoredState(revision, data);
    return revision;
  }

  @override
  Future<void> close() async => closes++;
}
