import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/webdav_sync_repository.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';

class _Conflict extends Error {}

class FakeWebdavTransport implements WebdavTransport {
  final Map<String, Uint8List> files = {};
  final Set<String> dirs = {};
  final List<String> removed = [];
  Map<String, dynamic>? lastWriteHeaders;
  Object? throwOnReadDir;

  @override
  Future<void> mkdirAll(String path) async => dirs.add(path);

  @override
  Future<List<WebdavFile>> readDir(String path) async {
    final err = throwOnReadDir;
    if (err != null) throw err;
    final prefix = path.endsWith('/') ? path : '$path/';
    final out = <WebdavFile>[];
    for (final p in files.keys) {
      if (!p.startsWith(prefix)) continue;
      final rest = p.substring(prefix.length);
      if (rest.contains('/')) continue;
      out.add(WebdavFile(path: p, isDir: false, name: rest));
    }
    return out;
  }

  @override
  Future<Uint8List> read(String path) async {
    final data = files[path];
    if (data == null) throw StateError('File not found: $path');
    return data;
  }

  @override
  Future<void> write(
    String path,
    Uint8List data, {
    Map<String, dynamic>? headers,
  }) async {
    lastWriteHeaders = headers;
    if (headers?.containsKey('If-None-Match') ?? false) {
      if (files.containsKey(path)) throw _Conflict();
    }
    files[path] = data;
    dirs.add(path.substring(0, path.lastIndexOf('/')));
  }

  @override
  Future<WebdavFile?> readProps(String path) async => null;

  @override
  Future<void> remove(String path) async {
    removed.add(path);
    files.remove(path);
    dirs.removeWhere((d) => d == path || d.startsWith('$path/'));
  }
}

WebdavSyncRepository repo(FakeWebdavTransport t) =>
    WebdavSyncRepository(transport: t);

SyncBatch batch(String id, DateTime createdAt) => SyncBatch(
  batchId: id,
  deviceId: 'dev1',
  createdAt: createdAt,
  changes: [
    SyncChange.upsert(
      entityType: 'note',
      entityId: 'n1',
      row: {'text': 'hello'},
    ),
  ],
);

void main() {
  test(
    'pushBatch creates magpie_nest/ and writes a file with valid JSON',
    () async {
      final t = FakeWebdavTransport();
      await repo(t).pushBatch(batch('b1', DateTime.utc(2026, 1, 2, 3, 4, 5)));

      expect(t.dirs, contains('magpie_nest/'));
      expect(t.files, hasLength(1));
      final path = t.files.keys.single;
      expect(path, startsWith('magpie_nest/'));
      expect(path, endsWith('-b1.json'));

      final decoded = jsonDecode(utf8.decode(t.files[path]!)) as Map;
      expect(decoded['batchId'], 'b1');
      expect(decoded['deviceId'], 'dev1');
      expect((decoded['changes'] as List), hasLength(1));
    },
  );

  test('pushBatch sends If-None-Match:* (append-only)', () async {
    final t = FakeWebdavTransport();
    await repo(t).pushBatch(batch('b2', DateTime.utc(2026, 1, 2, 3, 4, 6)));

    expect(t.lastWriteHeaders, isNotNull);
    expect(t.lastWriteHeaders!['If-None-Match'], '*');
  });

  test('fetchAfter(null) returns all records in alphabetical order', () async {
    final t = FakeWebdavTransport();
    await repo(t).pushBatch(batch('b1', DateTime.utc(2026, 1, 2, 3, 4, 5)));
    await repo(t).pushBatch(batch('b2', DateTime.utc(2026, 1, 2, 3, 5, 0)));

    final entries = await repo(t).fetchAfter(null);
    expect(entries, hasLength(2));
    expect(entries.first.batch.batchId, 'b1');
    expect(entries.last.batch.batchId, 'b2');
  });

  test(
    'fetchAfter(cursor) returns only the records after the cursor.',
    () async {
      final t = FakeWebdavTransport();
      await repo(t).pushBatch(batch('b1', DateTime.utc(2026, 1, 2, 3, 4, 5)));
      await repo(t).pushBatch(batch('b2', DateTime.utc(2026, 1, 2, 3, 5, 0)));

      final all = await repo(t).fetchAfter(null);
      final after = await repo(t).fetchAfter(all.first.file);
      expect(after, hasLength(1));
      expect(after.single.batch.batchId, 'b2');
    },
  );

  test('fetchAfter returns an empty log on a fresh device', () async {
    final t = FakeWebdavTransport();
    final entries = await repo(t).fetchAfter(null);
    expect(entries, isEmpty);
  });

  test('circulation: the launched batch returns via fetchAfter', () async {
    final t = FakeWebdavTransport();
    final pushed = batch('b1', DateTime.utc(2026, 1, 2, 3, 4, 5));
    await repo(t).pushBatch(pushed);

    final entries = await repo(t).fetchAfter(null);
    expect(entries, hasLength(1));
    final got = entries.single.batch;
    expect(got.batchId, 'b1');
    expect(got.deviceId, 'dev1');
    expect(got.changes, hasLength(1));
    expect(got.changes.single.row, isNotNull);
    expect(got.changes.single.row?['text'], 'hello');
    expect(got.createdAt.isAtSameMomentAs(pushed.createdAt), isTrue);
  });

  test('pushBatch writes into the configured journal directory', () async {
    final t = FakeWebdavTransport();
    final subject = WebdavSyncRepository(
      transport: t,
      journalDir: 'MyBackups/magpie/',
    );

    await subject.pushBatch(batch('b1', DateTime.utc(2026, 1, 2, 3, 4, 5)));

    expect(t.files.keys, hasLength(1));
    expect(t.files.keys.first, startsWith('MyBackups/magpie/'));
    expect(t.files.keys.first, endsWith('-b1.json'));
    expect(
      t.files.keys.first.startsWith('magpie_nest/'),
      isFalse,
      reason: 'the default dir must not be used for a custom journalDir',
    );
  });

  test('fetchAfter treats a missing journal folder (404) as an empty log', () async {
    final t = FakeWebdavTransport();
    t.throwOnReadDir = WebdavException(message: 'Resource not found', statusCode: 404);

    final entries = await repo(t).fetchAfter(null);
    expect(entries, isEmpty);
  });

  test('fetchAfter rethrows non-404 readDir errors', () async {
    final t = FakeWebdavTransport();
    t.throwOnReadDir = WebdavException(message: 'Access forbidden', statusCode: 403);

    expect(
      repo(t).fetchAfter(null),
      throwsA(isA<WebdavException>()),
    );
  });

  test('clearRemote deletes every batch file and the journal folder', () async {
    final t = FakeWebdavTransport();
    await repo(t).pushBatch(batch('b1', DateTime.utc(2026, 1, 2, 3, 4, 5)));
    await repo(t).pushBatch(batch('b2', DateTime.utc(2026, 1, 2, 3, 5, 0)));

    await repo(t).clearRemote();

    expect(t.files, isEmpty);
    expect(t.removed, contains('magpie_nest/'));
    expect(t.removed, hasLength(3)); // two batch files + the folder
  });

  test('clearRemote is a no-op when the journal folder is missing (404)', () async {
    final t = FakeWebdavTransport();
    t.throwOnReadDir = WebdavException(message: 'Resource not found', statusCode: 404);

    await repo(t).clearRemote();

    expect(t.removed, isEmpty);
  });

  test('clearRemote rethrows non-404 readDir errors', () async {
    final t = FakeWebdavTransport();
    t.throwOnReadDir = WebdavException(message: 'Access forbidden', statusCode: 403);

    expect(repo(t).clearRemote(), throwsA(isA<WebdavException>()));
  });

  test('refuses to construct with a root sync folder', () async {
    final t = FakeWebdavTransport();
    expect(
      () => WebdavSyncRepository(transport: t, journalDir: '/'),
      throwsStateError,
    );
  });
}
