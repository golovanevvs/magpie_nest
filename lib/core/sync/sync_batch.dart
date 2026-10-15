import 'package:magpie_nest/core/database/app_database.dart';

class SyncBatch {
  final String batchId;
  final String deviceId;
  final int cloudSeq;
  final DateTime createdAt;
  final List<SyncChange> changes;

  const SyncBatch({
    required this.batchId,
    required this.deviceId,
    required this.cloudSeq,
    required this.createdAt,
    required this.changes,
  });
}

class SyncChange {
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, Object?>? row;

  const SyncChange.upsert({
    required this.entityType,
    required this.entityId,
    required Map<String, Object?> this.row,
  }) : operation = Outbox.opUpsert;

  const SyncChange.delete({required this.entityType, required this.entityId})
    : operation = Outbox.opDelete,
      row = null;
}
