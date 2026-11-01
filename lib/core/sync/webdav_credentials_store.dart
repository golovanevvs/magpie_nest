import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';

abstract interface class WebdavCredentialsStore {
  Future<WebdavCredentials?> read();
  Future<void> save(WebdavCredentials credentials);
  Future<void> clear();
}

abstract interface class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureKeyValueStorage implements SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class SecureWebdavCredentialsStore implements WebdavCredentialsStore {
  static const _urlKey = 'webdav_url';
  static const _userKey = 'webdav_username';
  static const _pwdKey = 'webdav_password';
  static const _folderKey = 'webdav_folder';

  final SecureStorage _storage;

  SecureWebdavCredentialsStore([SecureStorage? storage])
    : _storage = storage ?? FlutterSecureKeyValueStorage();

  @override
  Future<WebdavCredentials?> read() async {
    final url = await _storage.read(_urlKey);
    if (url == null || url.isEmpty) return null;
    final username = await _storage.read(_userKey) ?? '';
    final password = await _storage.read(_pwdKey) ?? '';
    final folder = normalizeJournalDir(await _storage.read(_folderKey) ?? '');
    return WebdavCredentials(
      url: url,
      username: username,
      password: password,
      folder: folder,
    );
  }

  @override
  Future<void> save(WebdavCredentials credentials) async {
    await _storage.write(_urlKey, credentials.url);
    await _storage.write(_userKey, credentials.username);
    await _storage.write(_pwdKey, credentials.password);
    await _storage.write(_folderKey, credentials.folder);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(_urlKey);
    await _storage.delete(_userKey);
    await _storage.delete(_pwdKey);
    await _storage.delete(_folderKey);
  }
}
