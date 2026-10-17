import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_batch_codec.dart';

void main() {
  test('batch roundtrip through JSON preserves upsert and delete', () {
    const folderRow = {
      'id': 'f-100',
      'name': 'Work (renamed)',
      'parentId': null,
      'sortOrder': 1,
      'createdAt': '2026-10-17T10:00:00.000Z',
      'updatedAt': '2026-10-17T14:00:00.000Z',
      'isDeleted': false,
      'deletedAt': null,
      'revision': 3,
    };

    final batch = SyncBatch(
      batchId: 'batch-1',
      deviceId: 'device-a',
      cloudSeq: 0,
      createdAt: DateTime.utc(2026, 10, 17, 14),
      changes: [
        SyncChange.upsert(
          entityType: Outbox.entityTypeFolder,
          entityId: 'f-100',
          row: folderRow,
        ),
        SyncChange.delete(
          entityType: Outbox.entityTypeSnippet,
          entityId: 's-200',
        ),
      ],
    );

    final decoded =
        jsonDecode(jsonEncode(syncBatchToJson(batch))) as Map<String, Object?>;
    final restored = syncBatchFromJson(Map<String, Object?>.from(decoded));

    expect(restored.batchId, 'batch-1');
    expect(restored.deviceId, 'device-a');
    expect(restored.cloudSeq, 0);
    expect(restored.createdAt.isUtc, isTrue);
    expect(restored.createdAt, batch.createdAt);

    expect(restored.changes, hasLength(2));

    final upsert = restored.changes[0];
    expect(upsert.operation, Outbox.opUpsert);
    expect(upsert.entityType, Outbox.entityTypeFolder);
    expect(upsert.entityId, 'f-100');
    expect(upsert.row, folderRow);

    final delete = restored.changes[1];
    expect(delete.operation, Outbox.opDelete);
    expect(delete.entityId, 's-200');
    expect(delete.row, isNull);
  });
}
