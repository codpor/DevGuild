import 'package:sembast/sembast.dart';

class StoredState {
  final int revision;
  final Map<String, Object?> data;
  StoredState(this.revision, this.data);
}

class StorageConflict implements Exception {
  const StorageConflict();
}

abstract class StateStore {
  Future<StoredState?> read();
  Future<int> write(Map<String, Object?> data, {required int expectedRevision});
  Future<void> close();
}

/// Satu transaksi menyimpan seluruh perubahan lintas provider secara konsisten.
class DatabaseStateStore implements StateStore {
  final Database database;
  static final _record = stringMapStoreFactory
      .store('devguild')
      .record('state');
  DatabaseStateStore(this.database);

  @override
  Future<StoredState?> read() async {
    final record = await _record.get(database);
    if (record == null) return null;
    return StoredState(
      record['revision'] as int,
      Map<String, Object?>.from(record['data'] as Map),
    );
  }

  @override
  Future<int> write(
    Map<String, Object?> data, {
    required int expectedRevision,
  }) => database.transaction((transaction) async {
    final existing = await _record.get(transaction);
    final revision = existing == null ? 0 : existing['revision'] as int;
    // Tolak snapshot lama saat revisi database sudah berubah.
    if (revision != expectedRevision) throw const StorageConflict();
    final nextRevision = revision + 1;
    await _record.put(transaction, {'revision': nextRevision, 'data': data});
    return nextRevision;
  });

  @override
  Future<void> close() => database.close();
}
