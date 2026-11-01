import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
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

WebdavCredentials credentials() => const WebdavCredentials(
  url: 'https://dav.example.com/',
  username: 'user',
  password: 'secret',
);

Future<void> passingTester(WebdavCredentials credentials) async {}

Future<void> failingTester(WebdavCredentials credentials) async {
  throw Exception('boom');
}

void main() {
  test('load restores connected state from the store', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());
    await store.save(credentials());
    final controller = CloudConnectionController(
      store: store,
      tester: passingTester,
    );

    await controller.load();

    expect(controller.status, CloudConnectionStatus.connected);
    expect(controller.isConnected, isTrue);
    expect(controller.connectedUrl, 'https://dav.example.com/');
    expect(controller.error, isNull);
  });

  test('load with empty store leaves notConfigured', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());
    final controller = CloudConnectionController(
      store: store,
      tester: failingTester,
    );

    await controller.load();

    expect(controller.status, CloudConnectionStatus.notConfigured);
    expect(controller.isConnected, isFalse);
    expect(controller.connectedUrl, isNull);
  });

  test(
    'connect with a passing tester saves credentials and reports connected',
    () async {
      final store = SecureWebdavCredentialsStore(FakeSecureStorage());
      final controller = CloudConnectionController(
        store: store,
        tester: passingTester,
      );

      final ok = await controller.connect(credentials());

      expect(ok, isTrue);
      expect(controller.isConnected, isTrue);
      expect(controller.connectedUrl, 'https://dav.example.com/');
      expect(controller.error, isNull);
      final stored = await store.read();
      expect(stored, isNotNull);
      expect(stored!.url, 'https://dav.example.com/');
      expect(stored.username, 'user');
      expect(stored.password, 'secret');
    },
  );

  test(
    'connect with a failing tester does not save and reports error',
    () async {
      final store = SecureWebdavCredentialsStore(FakeSecureStorage());
      final controller = CloudConnectionController(
        store: store,
        tester: failingTester,
      );

      final ok = await controller.connect(credentials());

      expect(ok, isFalse);
      expect(controller.isConnected, isFalse);
      expect(controller.error, contains('boom'));
      expect(await store.read(), isNull);
    },
  );

  test('connect with a blank url fails without calling the tester', () async {
    var testerCalled = false;
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());
    final controller = CloudConnectionController(
      store: store,
      tester: (credentials) async {
        testerCalled = true;
      },
    );
    const blank = WebdavCredentials(url: '  ', username: 'u', password: 'p');

    final ok = await controller.connect(blank);

    expect(ok, isFalse);
    expect(testerCalled, isFalse);
    expect(await store.read(), isNull);
  });

  test('disconnect clears the store and returns to notConfigured', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());
    final controller = CloudConnectionController(
      store: store,
      tester: passingTester,
    );
    await controller.connect(credentials());

    await controller.disconnect();

    expect(controller.isConnected, isFalse);
    expect(controller.status, CloudConnectionStatus.notConfigured);
    expect(controller.connectedUrl, isNull);
    expect(controller.error, isNull);
    expect(await store.read(), isNull);
  });

  test('testConnection does not save credentials', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());
    final controller = CloudConnectionController(
      store: store,
      tester: passingTester,
    );

    final ok = await controller.testConnection(credentials());

    expect(ok, isTrue);
    expect(controller.isConnected, isFalse);
    expect(await store.read(), isNull);
  });

  test(
    'run sets busy while the tester is in flight and clears it after',
    () async {
      final store = SecureWebdavCredentialsStore(FakeSecureStorage());
      final gate = Completer<void>();
      final controller = CloudConnectionController(
        store: store,
        tester: (credentials) => gate.future,
      );

      final inFlight = controller.connect(credentials());
      expect(controller.busy, isTrue);

      gate.complete();
      expect(await inFlight, isTrue);
      expect(controller.busy, isFalse);
    },
  );
}
