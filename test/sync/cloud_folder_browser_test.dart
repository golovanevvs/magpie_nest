import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/sync/cloud_folder_browser.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';

class FakeWebdavTransport implements WebdavTransport {
  final Map<String, Uint8List> files = {};
  final Set<String> dirs = {};
  Object? throwOnReadDir;

  String _norm(String p) => p.startsWith('/') ? p.substring(1) : p;

  @override
  Future<void> mkdirAll(String path) async {
    final clean = _norm(path);
    dirs.add(
      clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean,
    );
  }

  @override
  Future<List<WebdavFile>> readDir(String path) async {
    final err = throwOnReadDir;
    if (err != null) throw err;
    final prefix = _norm(path);
    final out = <WebdavFile>[];
    for (final d in dirs) {
      if (prefix.isNotEmpty && !d.startsWith(prefix)) continue;
      final rest = d.substring(prefix.length);
      if (rest.isEmpty || rest.contains('/')) continue;
      out.add(WebdavFile(path: d, isDir: true, name: rest));
    }
    for (final p in files.keys) {
      if (prefix.isNotEmpty && !p.startsWith(prefix)) continue;
      final rest = p.substring(prefix.length);
      if (rest.isEmpty || rest.contains('/')) continue;
      out.add(WebdavFile(path: p, isDir: false, name: rest));
    }
    return out;
  }

  @override
  Future<Uint8List> read(String path) async => files[_norm(path)]!;

  @override
  Future<void> write(
    String path,
    Uint8List data, {
    Map<String, dynamic>? headers,
  }) async => files[_norm(path)] = data;

  @override
  Future<WebdavFile?> readProps(String path) async => null;
}

CloudFolderBrowser browser(FakeWebdavTransport t, {String initialPath = ''}) =>
    CloudFolderBrowser(transport: t, initialPath: initialPath);

FakeWebdavTransport seeded() {
  final t = FakeWebdavTransport();
  t.dirs.addAll({'docs', 'backup', 'docs/archive'});
  t.files['docs/readme.txt'] = Uint8List(0);
  return t;
}

void main() {
  test('reload from root lists only folders, sorted', () async {
    final subject = browser(seeded());

    await subject.reload();

    expect(subject.atRoot, isTrue);
    expect(subject.path, '');
    expect(subject.folders, ['backup', 'docs']);
  });

  test('enter and up navigate the tree', () async {
    final subject = browser(seeded());
    await subject.reload();

    await subject.enter('docs');
    expect(subject.path, 'docs/');
    expect(subject.atRoot, isFalse);
    expect(subject.folders, ['archive']);

    await subject.up();
    expect(subject.path, '');
    expect(subject.atRoot, isTrue);
    expect(subject.folders, ['backup', 'docs']);
  });

  test('browser starts at the given initial path', () async {
    final subject = browser(seeded(), initialPath: '/docs');

    expect(subject.path, 'docs/');
    expect(subject.atRoot, isFalse);

    await subject.reload();
    expect(subject.folders, ['archive']);
  });

  test('createFolder makes the directory and descends into it', () async {
    final t = seeded();
    final subject = browser(t);
    await subject.reload();

    await subject.createFolder('magpie');

    expect(t.dirs, contains('magpie'));
    expect(subject.path, 'magpie/');
    expect(subject.folders, isEmpty);
  });

  test('createFolder rejects invalid names', () async {
    final t = seeded();
    final subject = browser(t);
    await subject.reload();

    for (final bad in ['', '  ', 'a/b', '..', 'x/../y']) {
      await expectLater(
        subject.createFolder(bad),
        throwsArgumentError,
        reason: 'name: "$bad"',
      );
    }
    expect(t.dirs, isNot(contains('magpie')));
    expect(subject.path, '');
  });

  test('error state on transport failure, retry via reload', () async {
    final t = seeded()..throwOnReadDir = Exception('offline');
    final subject = browser(t);

    await subject.reload();

    expect(subject.error, contains('offline'));
    expect(subject.busy, isFalse);
    expect(subject.folders, isEmpty);

    t.throwOnReadDir = null;
    await subject.reload();

    expect(subject.error, isNull);
    expect(subject.folders, ['backup', 'docs']);
  });
}
