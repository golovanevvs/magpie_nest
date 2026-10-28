import 'dart:typed_data';

import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';

abstract interface class WebdavTransport {
  Future<void> mkdirAll(String path);
  Future<List<WebdavFile>> readDir(String path);
  Future<Uint8List> read(String path);
  Future<void> write(
    String path,
    Uint8List data, {
    Map<String, dynamic>? headers,
  });
  Future<WebdavFile?> readProps(String path);
  Future<void> remove(String path);
}

class WebdavTransportAdapter implements WebdavTransport {
  final WebdavClient client;
  WebdavTransportAdapter(this.client);

  @override
  Future<void> mkdirAll(String path) => client.mkdirAll(path);
  @override
  Future<List<WebdavFile>> readDir(String path) => client.readDir(path);
  @override
  Future<Uint8List> read(String path) => client.read(path);
  @override
  Future<void> write(
    String path,
    Uint8List data, {
    Map<String, dynamic>? headers,
  }) => client.write(path, data, headers: headers);
  @override
  Future<WebdavFile?> readProps(String path) => client.readProps(path);
  @override
  Future<void> remove(String path) => client.remove(path);
}

WebdavClient webdavClientFrom(WebdavCredentials credentials) {
  if (credentials.isNoAuth) return WebdavClient.noAuth(url: credentials.url);
  return WebdavClient.basicAuth(
    url: credentials.url,
    user: credentials.username,
    pwd: credentials.password,
  );
}

WebdavTransport webdavTransportFrom(WebdavCredentials credentials) =>
    WebdavTransportAdapter(webdavClientFrom(credentials));
