import 'package:flutter_test/flutter_test.dart';
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

void main() {
  test('read returns null when nothing is stored', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());

    expect(await store.read(), isNull);
  });

  test('save then read roundtrips url, username and password', () async {
    final fake = FakeSecureStorage();
    final store = SecureWebdavCredentialsStore(fake);

    await store.save(credentials());
    final read = await store.read();

    expect(read, isNotNull);
    expect(read!.url, 'https://dav.example.com/');
    expect(read.username, 'user');
    expect(read.password, 'secret');
    expect(fake.values, containsPair('webdav_password', 'secret'));
  });

  test('clear removes credentials so read returns null', () async {
    final fake = FakeSecureStorage();
    final store = SecureWebdavCredentialsStore(fake);

    await store.save(credentials());
    await store.clear();

    expect(fake.values, isEmpty);
    expect(await store.read(), isNull);
  });

  test(
    'no-auth credentials (empty username/password) still roundtrip',
    () async {
      final store = SecureWebdavCredentialsStore(FakeSecureStorage());

      await store.save(
        const WebdavCredentials(
          url: 'https://dav.example.com/',
          username: '',
          password: '',
        ),
      );
      final read = await store.read();

      expect(read, isNotNull);
      expect(read!.isConfigured, isTrue);
      expect(read.isNoAuth, isTrue);
    },
  );

  test('save overwrites previously stored credentials', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());

    await store.save(credentials());
    await store.save(
      const WebdavCredentials(
        url: 'https://other.example.com/',
        username: 'u2',
        password: 'p2',
      ),
    );
    final read = await store.read();

    expect(read!.url, 'https://other.example.com/');
    expect(read.username, 'u2');
    expect(read.password, 'p2');
  });

  test('save/read roundtrips the folder', () async {
    final store = SecureWebdavCredentialsStore(FakeSecureStorage());

    await store.save(
      const WebdavCredentials(
        url: 'https://dav.example.com/',
        username: '',
        password: '',
        folder: 'MyBackups/magpie/',
      ),
    );
    final read = await store.read();

    expect(read!.folder, 'MyBackups/magpie/');
  });

  test(
    'read falls back to the default dir when the folder key is missing',
    () async {
      final fake = FakeSecureStorage();
      fake.values['webdav_url'] = 'https://dav.example.com/';
      fake.values['webdav_username'] = '';
      fake.values['webdav_password'] = '';
      final store = SecureWebdavCredentialsStore(fake);

      final read = await store.read();

      expect(read!.folder, 'magpie_nest/');
    },
  );

  test('WebdavCredentials helpers: isConfigured and isNoAuth', () {
    expect(credentials().isConfigured, isTrue);
    expect(credentials().isNoAuth, isFalse);

    const noAuth = WebdavCredentials(
      url: 'https://dav.example.com/',
      username: '',
      password: '',
    );
    expect(noAuth.isNoAuth, isTrue);
    expect(noAuth.isConfigured, isTrue);

    const blankUrl = WebdavCredentials(url: '  ', username: 'u', password: 'p');
    expect(blankUrl.isConfigured, isFalse);
  });
}
