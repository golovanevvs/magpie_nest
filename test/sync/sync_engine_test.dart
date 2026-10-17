import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_engine.dart';
import 'package:magpie_nest/features/snippets/data/repositories/drift_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';

import 'in_memory_sync_repository.dart';

void main() {
  late InMemorySyncRepository cloud;
  late AppDatabase dbA;
  late AppDatabase dbB;
  late SyncEngine engineA;
  late SyncEngine engineB;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() async {
    cloud = InMemorySyncRepository();
    dbA = AppDatabase(NativeDatabase.memory());
    dbB = AppDatabase(NativeDatabase.memory());
    await dbA.setSyncMeta('deviceId', 'device-A');
    await dbB.setSyncMeta('deviceId', 'device-B');
    engineA = SyncEngine(db: dbA, syncRepository: cloud);
    engineB = SyncEngine(db: dbB, syncRepository: cloud);
  });

  tearDown(() async {
    await dbA.close();
    await dbB.close();
  });

  test('assigns monotonic cloudSeq and returns batches after cursor', () async {
    final cloud = InMemorySyncRepository();
    await cloud.pushBatch(_batchWithDevice('a'));
    await cloud.pushBatch(_batchWithDevice('b'));

    final all = await cloud.fetchBatchesSince(0);
    expect(all.map((b) => b.cloudSeq), [1, 2]);

    final tail = await cloud.fetchBatchesSince(1);
    expect(tail.single.deviceId, 'b');
  });

  test(
    'snippet created on A reaches B with identical payload fields',
    () async {
      final repoA = DriftSnippetRepository(dbA);
      final repoB = DriftSnippetRepository(dbB);

      final fragment = Fragment(
        id: 'frag-1',
        name: 'main',
        language: 'dart',
        content: 'void main() {}',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final snippet = Snippet(
        id: 'snip-1',
        name: 'Hello',
        fragments: [fragment],
        activeFragmentId: 'frag-1',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      await repoA.saveSnippet(snippet);
      await engineA.syncNow();
      await engineB.syncNow();

      final received = await repoB.getSnippetById('snip-1');
      expect(received, isNotNull);
      expect(received!.name, 'Hello');
      expect(received.fragments, hasLength(1));
      expect(received.fragments.single.id, 'frag-1');
      expect(received.fragments.single.content, 'void main() {}');
      expect(received.activeFragmentId, 'frag-1');
    },
  );

  test(
    'two edits without sync produce one coalesced upsert with final state',
    () async {
      final repoA = DriftSnippetRepository(dbA);

      final fragment = Fragment(
        id: 'frag-1',
        name: 'main',
        language: 'dart',
        content: 'v1',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final base = Snippet(
        id: 'snip-1',
        name: 'v1',
        fragments: [fragment],
        activeFragmentId: 'frag-1',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      await repoA.saveSnippet(base);
      await repoA.saveSnippet(base.copyWith(name: 'v2'));

      await engineA.syncNow();

      final batch = cloud.pushed.single;
      final snippetChanges = batch.changes
          .where((c) => c.entityType == Outbox.entityTypeSnippet)
          .toList();
      expect(snippetChanges, hasLength(1));
      expect(snippetChanges.single.row!['name'], 'v2');
    },
  );

  test('tombstone propagates: B keeps the row flagged as deleted', () async {
    final repoA = DriftSnippetRepository(dbA);
    final repoB = DriftSnippetRepository(dbB);

    await repoA.saveSnippet(_makeSnippet());
    await engineA.syncNow();
    await engineB.syncNow();

    await repoA.deleteSnippet('snip-1');
    await engineA.syncNow();
    await engineB.syncNow();

    final atB = await repoB.getSnippetById('snip-1');
    expect(atB, isNotNull);
    expect(atB!.isDeleted, isTrue);
  });

  test('restore propagates back to not-deleted', () async {
    final repoA = DriftSnippetRepository(dbA);
    final repoB = DriftSnippetRepository(dbB);

    await repoA.saveSnippet(_makeSnippet());
    await engineA.syncNow();
    await engineB.syncNow();

    await repoA.deleteSnippet('snip-1');
    await engineA.syncNow();
    await engineB.syncNow();

    await repoA.restoreSnippet('snip-1');
    await engineA.syncNow();
    await engineB.syncNow();

    final atB = await repoB.getSnippetById('snip-1');
    expect(atB, isNotNull);
    expect(atB!.isDeleted, isFalse);
  });

  test('purge removes the row physically on B', () async {
    final repoA = DriftSnippetRepository(dbA);
    final repoB = DriftSnippetRepository(dbB);

    await repoA.saveSnippet(_makeSnippet());
    await engineA.syncNow();
    await engineB.syncNow();

    await repoA.deleteSnippet('snip-1');
    await repoA.permanentlyDeleteSnippet('snip-1');
    await engineA.syncNow();
    await engineB.syncNow();

    final atB = await repoB.getSnippetById('snip-1');
    expect(atB, isNull);
  });

  test('echo: A pulling its own batches does not duplicate anything', () async {
    final repoA = DriftSnippetRepository(dbA);

    await repoA.saveSnippet(_makeSnippet());
    await engineA.syncNow();
    await engineA.syncNow();

    final ownBatches = cloud.pushed
        .where((b) => b.deviceId == 'device-A')
        .toList();
    expect(ownBatches, hasLength(1));

    final atA = await repoA.getSnippetById('snip-1');
    expect(atA, isNotNull);
    expect(atA!.name, 'Hello');
  });

  test('LWW: equal revisions, later updatedAt wins on both devices', () async {
    final repoA = DriftSnippetRepository(dbA);
    final repoB = DriftSnippetRepository(dbB);
    const id = 'snip-1';

    await repoA.saveSnippet(_makeSnippet());
    await engineA.syncNow();
    await engineB.syncNow();

    await repoA.saveSnippet(
      (await repoA.getSnippetById(id))!.copyWith(name: 'from A'),
    );
    await repoB.saveSnippet(
      (await repoB.getSnippetById(id))!.copyWith(name: 'from B'),
    );

    await (dbA.update(dbA.snippets)..where((t) => t.id.equals(id))).write(
      SnippetsCompanion(updatedAt: Value(DateTime.utc(2026, 1, 1, 10))),
    );
    await (dbB.update(dbB.snippets)..where((t) => t.id.equals(id))).write(
      SnippetsCompanion(updatedAt: Value(DateTime.utc(2026, 1, 1, 11))),
    );

    await engineA.syncNow();
    await engineB.syncNow();
    await engineA.syncNow();

    final atA = await repoA.getSnippetById(id);
    final atB = await repoB.getSnippetById(id);
    expect(atA!.name, 'from B');
    expect(atB!.name, 'from B');
  });
}

Snippet _makeSnippet({String id = 'snip-1', String name = 'Hello'}) {
  final fragment = Fragment(
    id: 'frag-1',
    name: 'main',
    language: 'dart',
    content: 'void main() {}',
    updatedAt: DateTime.utc(2026, 1, 1),
  );
  return Snippet(
    id: id,
    name: name,
    fragments: [fragment],
    activeFragmentId: 'frag-1',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

SyncBatch _batchWithDevice(String deviceId) {
  return SyncBatch(
    batchId: 'batch-$deviceId',
    deviceId: deviceId,
    cloudSeq: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    changes: const [],
  );
}
