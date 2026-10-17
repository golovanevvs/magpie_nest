import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';

Map<String, Object?> syncBatchToJson(SyncBatch batch) {
  return {
    'batchId': batch.batchId,
    'deviceId': batch.deviceId,
    'cloudSeq': batch.cloudSeq,
    'createdAt': batch.createdAt.toUtc().toIso8601String(),
    'changes': [for (final change in batch.changes) _changeToJson(change)],
  };
}

Map<String, Object?> _changeToJson(SyncChange change) {
  final json = <String, Object?>{
    'entityType': change.entityType,
    'entityId': change.entityId,
    'operation': change.operation,
  };
  if (change.row != null) json['row'] = change.row;
  return json;
}

SyncBatch syncBatchFromJson(Map<String, Object?> json) {
  final rawChanges = json['changes'] as List<Object?>;
  final changes = <SyncChange>[];
  for (final rawChange in rawChanges) {
    final changeJson = Map<String, Object?>.from(rawChange! as Map);
    final entityType = changeJson['entityType']! as String;
    final entityId = changeJson['entityId']! as String;
    final operation = changeJson['operation']! as String;
    switch (operation) {
      case Outbox.opUpsert:
        final row = Map<String, Object?>.from(changeJson['row']! as Map);
        changes.add(
          SyncChange.upsert(
            entityType: entityType,
            entityId: entityId,
            row: row,
          ),
        );
      case Outbox.opDelete:
        changes.add(
          SyncChange.delete(entityType: entityType, entityId: entityId),
        );
      default:
        throw StateError('Unknown operation: $operation');
    }
  }
  return SyncBatch(
    batchId: json['batchId']! as String,
    deviceId: json['deviceId']! as String,
    cloudSeq: json['cloudSeq']! as int,
    createdAt: DateTime.parse(json['createdAt']! as String),
    changes: changes,
  );
}
