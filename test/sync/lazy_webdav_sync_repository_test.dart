import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/sync/lazy_webdav_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_batch_codec.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';

class FakeSecureStorage implements SecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FakeWebdavTransport implements WebdavTransport {
  final Map<String, Uint8List> files = {};

  @override
  Future<void> mkdirAll(String path) async {}

  @override
  Future<List<WebdavFile>> readDir(String path) async {
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
  }) async => files[path] = data;

  @override
  Future<WebdavFile?> readProps(String path) async => null;
}

const credentials = WebdavCredentials(
  url: 'https://dav.example.com/',
  username: '',
  password: '',
);

SyncBatch batch(String id) => SyncBatch(
  batchId: id,
  deviceId: 'dev1',
  createdAt: DateTime.utc(2026, 1, 1),
  changes: [
    SyncChange.upsert(
      entityType: 'note',
      entityId: 'n1',
      row: {'text': 'hello'},
    ),
  ],
);

Uint8List encoded(SyncBatch b) =>
    Uint8List.fromList(utf8.encode(jsonEncode(syncBatchToJson(b))));

LazyWebdavSyncRepository repo(
  WebdavCredentialsStore store,
  FakeWebdavTransport t,
) => LazyWebdavSyncRepository(store: store, transportFactory: (_) => t);

void main() {
  test('pushBatch throws when credentials are not stored', () async {
    var factoryCalled = false;
    WebdavTransport factory(WebdavCredentials c) {
      factoryCalled = true;
      throw StateError('must not be called');
    }

    final subject = LazyWebdavSyncRepository(
      store: SecureWebdavCredentialsStore(FakeSecureStorage()),
      transportFactory: factory,
    );

    await expectLater(subject.pushBatch(batch('b1')), throwsStateError);
    expect(factoryCalled, isFalse);
  });

  test(
    'pushBatch writes the batch to the transport built from stored credentials',
    () async {
      final transport = FakeWebdavTransport();
      final store = SecureWebdavCredentialsStore(FakeSecureStorage());
      await store.save(credentials);
      final subject = repo(store, transport);

      await subject.pushBatch(batch('b1'));

      expect(transport.files.keys, hasLength(1));
      final path = transport.files.keys.first;
      expect(path, startsWith('magpie_nest/'));
      expect(path, contains('b1'));
      final json = jsonDecode(utf8.decode(transport.files[path]!)) as Map;
      expect(json['batchId'], 'b1');
    },
  );

  test('fetchAfter reads journal files after the cursor', () async {
    final transport = FakeWebdavTransport();
    transport.files['magpie_nest/2026-a.json'] = encoded(batch('bA'));
    transport.files['magpie_nest/2026-b.json'] = encoded(batch('bB'));
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());
    await store.save(credentials);
    final subject = repo(store, transport);

    final all = await subject.fetchAfter(null);
    expect(all, hasLength(2));
    expect(all[0].file, '2026-a.json');
    expect(all[0].batch.batchId, 'bA');
    expect(all[1].file, '2026-b.json');

    final after = await subject.fetchAfter('2026-a.json');
    expect(after, hasLength(1));
    expect(after[0].batch.batchId, 'bB');
  });
}
