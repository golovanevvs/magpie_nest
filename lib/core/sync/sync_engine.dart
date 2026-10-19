import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/sync/i_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_row_codec.dart';
import 'package:uuid/uuid.dart';

class SyncEngine {
  final AppDatabase _db;
  final ISyncRepository _syncRepository;

  SyncEngine({required this._db, required this._syncRepository});

  Future<void> pushPending() async {
    final entries = await _db.getPendingOutboxEntries();
    if (entries.isEmpty) return;

    final changes = <SyncChange>[];
    for (final entry in entries) {
      final change = await _toChange(entry);
      if (change != null) changes.add(change);
    }

    final coalesced = _coalesceChanges(changes);

    if (coalesced.isEmpty) {
      await _db.markOutboxEntriesSynced(entries.map((e) => e.seq).toList());
      return;
    }

    final batch = SyncBatch(
      batchId: const Uuid().v4(),
      deviceId: await _db.getDeviceId(),
      createdAt: DateTime.now(),
      changes: coalesced,
    );

    await _syncRepository.pushBatch(batch);
    await _db.markOutboxEntriesSynced(entries.map((e) => e.seq).toList());
  }

  Future<void> pullRemote() async {
    final myDeviceId = await _db.getDeviceId();
    final cursor = await _db.getSyncMeta('lastPulledJournalFile');

    final entries = await _syncRepository.fetchAfter(cursor);

    String? lastFile;
    for (final entry in entries) {
      lastFile = entry.file;
      if (entry.batch.deviceId == myDeviceId) continue;

      for (final change in entry.batch.changes) {
        await _applyRemoteChange(change, originDeviceId: entry.batch.deviceId);
      }
    }

    if (lastFile != null) {
      await _db.setSyncMeta('lastPulledJournalFile', lastFile);
    }
  }

  Future<void> syncNow() async {
    await pushPending();
    await pullRemote();
  }

  List<SyncChange> _coalesceChanges(List<SyncChange> changes) {
    final coalesced = <SyncChange>[];
    final position = <String, int>{};
    for (final change in changes) {
      final key = '${change.entityType}/${change.entityId}/${change.operation}';
      final existing = position[key];
      if (existing != null) {
        coalesced[existing] = change;
      } else {
        position[key] = coalesced.length;
        coalesced.add(change);
      }
    }
    return coalesced;
  }

  Future<SyncChange?> _toChange(OutboxEntryRow entry) async {
    if (entry.operation == Outbox.opDelete) {
      return SyncChange.delete(
        entityType: entry.entityType,
        entityId: entry.entityId,
      );
    }
    final payload = await _readCurrentState(entry.entityType, entry.entityId);
    if (payload == null) return null;
    return SyncChange.upsert(
      entityType: entry.entityType,
      entityId: entry.entityId,
      row: payload,
    );
  }

  Future<Map<String, Object?>?> _readCurrentState(
    String entityType,
    String entityId,
  ) async {
    switch (entityType) {
      case Outbox.entityTypeFolder:
        final row = await (_db.select(
          _db.folders,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row == null ? null : folderToPayload(row);
      case Outbox.entityTypeSnippet:
        final row = await (_db.select(
          _db.snippets,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row == null ? null : snippetToPayload(row);
      case Outbox.entityTypeFragment:
        final row = await (_db.select(
          _db.fragments,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row == null ? null : fragmentToPayload(row);
      default:
        throw StateError('Unknown entityType: $entityType');
    }
  }

  Future<void> _applyRemoteChange(
    SyncChange change, {
    required String originDeviceId,
  }) async {
    if (change.operation == Outbox.opDelete) {
      await _applyRemoteDelete(change.entityType, change.entityId);
      return;
    }
    await _applyRemoteUpsert(change);
  }

  Future<void> _applyRemoteUpsert(SyncChange change) async {
    final payload = change.row!;
    final remoteRevision = payload['revision']! as int;
    final remoteUpdatedAt = DateTime.parse(payload['updatedAt']! as String);

    final local = await _readLocalRow(change.entityType, change.entityId);

    if (local == null) {
      await _writeRemoteRow(change.entityType, payload);
      return;
    }

    if (local.revision > remoteRevision) return;
    if (local.revision < remoteRevision) {
      await _writeRemoteRow(change.entityType, payload);
      return;
    }

    if (local.updatedAt.isAfter(remoteUpdatedAt)) return;
    if (local.updatedAt.isBefore(remoteUpdatedAt)) {
      await _writeRemoteRow(change.entityType, payload);
      return;
    }
  }

  Future<({int revision, DateTime updatedAt})?> _readLocalRow(
    String entityType,
    String entityId,
  ) async {
    switch (entityType) {
      case Outbox.entityTypeFolder:
        final row = await (_db.select(
          _db.folders,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row == null
            ? null
            : (revision: row.revision, updatedAt: row.updatedAt);
      case Outbox.entityTypeSnippet:
        final row = await (_db.select(
          _db.snippets,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row == null
            ? null
            : (revision: row.revision, updatedAt: row.updatedAt);
      case Outbox.entityTypeFragment:
        final row = await (_db.select(
          _db.fragments,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row == null
            ? null
            : (revision: row.revision, updatedAt: row.updatedAt);
      default:
        throw StateError('Unknown entityType: $entityType');
    }
  }

  Future<void> _writeRemoteRow(
    String entityType,
    Map<String, Object?> payload,
  ) async {
    switch (entityType) {
      case Outbox.entityTypeFolder:
        await _db
            .into(_db.folders)
            .insertOnConflictUpdate(folderFromPayload(payload));
      case Outbox.entityTypeSnippet:
        await _db
            .into(_db.snippets)
            .insertOnConflictUpdate(snippetFromPayload(payload));
      case Outbox.entityTypeFragment:
        final parentId = payload['snippetId']! as String;
        final parent = await (_db.select(
          _db.snippets,
        )..where((t) => t.id.equals(parentId))).getSingleOrNull();
        if (parent == null) return;
        await _db
            .into(_db.fragments)
            .insertOnConflictUpdate(fragmentFromPayload(payload));
      default:
        throw StateError('Unknown entityType: $entityType');
    }
  }

  Future<void> _applyRemoteDelete(String entityType, String entityId) async {
    switch (entityType) {
      case Outbox.entityTypeFolder:
        await (_db.delete(
          _db.folders,
        )..where((t) => t.id.equals(entityId))).go();

      case Outbox.entityTypeSnippet:
        await (_db.delete(
          _db.snippets,
        )..where((t) => t.id.equals(entityId))).go();

      case Outbox.entityTypeFragment:
        await (_db.delete(
          _db.fragments,
        )..where((t) => t.id.equals(entityId))).go();

      default:
        throw StateError('Unknown entityType: $entityType');
    }
  }
}
