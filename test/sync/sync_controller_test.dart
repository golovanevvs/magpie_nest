import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';

class FakeSecureStorage implements SecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

Future<void> passingTester(WebdavCredentials credentials) async {}

Future<CloudConnectionController> connectedCloud() async {
  final cloud = CloudConnectionController(
    store: SecureWebdavCredentialsStore(FakeSecureStorage()),
    tester: passingTester,
  );
  await cloud.connect(
    const WebdavCredentials(
      url: 'https://dav.example.com/',
      username: '',
      password: '',
    ),
  );
  return cloud;
}

void main() {
  test('syncNow without a cloud connection does not run the engine', () async {
    var engineCalled = false;
    final cloud = CloudConnectionController(
      store: SecureWebdavCredentialsStore(FakeSecureStorage()),
      tester: passingTester,
    );
    final sync = SyncController(
      runner: () async => engineCalled = true,
      cloud: cloud,
    );

    final ok = await sync.syncNow();

    expect(ok, isFalse);
    expect(engineCalled, isFalse);
    expect(sync.error, isNull);
  });

  test(
    'syncNow with a connection runs the engine and records the time',
    () async {
      var engineCalled = false;
      final sync = SyncController(
        runner: () async => engineCalled = true,
        cloud: await connectedCloud(),
      );

      final ok = await sync.syncNow();

      expect(ok, isTrue);
      expect(engineCalled, isTrue);
      expect(sync.lastSyncedAt, isNotNull);
      expect(sync.error, isNull);
    },
  );

  test('syncNow reports errors from the engine', () async {
    final sync = SyncController(
      runner: () async => throw Exception('offline'),
      cloud: await connectedCloud(),
    );

    final ok = await sync.syncNow();

    expect(ok, isFalse);
    expect(sync.error, contains('offline'));
    expect(sync.lastSyncedAt, isNull);
  });

  test('syncNow ignores concurrent calls', () async {
    final gate = Completer<void>();
    final sync = SyncController(
      runner: () => gate.future,
      cloud: await connectedCloud(),
    );

    final inFlight = sync.syncNow();
    expect(sync.syncing, isTrue);

    final second = await sync.syncNow();
    expect(second, isFalse);

    gate.complete();
    expect(await inFlight, isTrue);
    expect(sync.syncing, isFalse);
  });

  test('purgeRemote without a cloud connection does not run the purge runner', () async {
    var purgeCalled = false;
    final cloud = CloudConnectionController(
      store: SecureWebdavCredentialsStore(FakeSecureStorage()),
      tester: passingTester,
    );
    final sync = SyncController(
      runner: () async {},
      purgeRunner: () async => purgeCalled = true,
      cloud: cloud,
    );

    final ok = await sync.purgeRemote();

    expect(ok, isFalse);
    expect(purgeCalled, isFalse);
    expect(sync.error, isNull);
  });

  test('purgeRemote with a connection runs the purge runner', () async {
    var purgeCalled = false;
    final sync = SyncController(
      runner: () async {},
      purgeRunner: () async => purgeCalled = true,
      cloud: await connectedCloud(),
    );

    final ok = await sync.purgeRemote();

    expect(ok, isTrue);
    expect(purgeCalled, isTrue);
    expect(sync.purging, isFalse);
    expect(sync.error, isNull);
  });

  test('purgeRemote reports errors from the purge runner', () async {
    final sync = SyncController(
      runner: () async {},
      purgeRunner: () async => throw Exception('dav offline'),
      cloud: await connectedCloud(),
    );

    final ok = await sync.purgeRemote();

    expect(ok, isFalse);
    expect(sync.error, contains('dav offline'));
  });
}
