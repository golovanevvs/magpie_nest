import 'package:flutter/foundation.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';

/// Lazily browses the WebDAV folder tree: one readDir per level.
class CloudFolderBrowser extends ChangeNotifier {
  final WebdavTransport _transport;

  String _path = ''; // '' = root; otherwise 'a/b/' with a trailing '/'
  List<String> _folders = [];
  bool _busy = false;
  String? _error;

  CloudFolderBrowser({
    required this._transport,
    String initialPath = '',
  }) {
    _path = normalizeJournalDir(initialPath, fallback: '');
  }

  String get path => _path;
  List<String> get folders => List.unmodifiable(_folders);
  bool get busy => _busy;
  String? get error => _error;
  bool get atRoot => _path.isEmpty;

  Future<void> reload() => _load(_path);

  Future<void> enter(String name) => _load('$_path$name/');

  Future<void> up() {
    if (atRoot) return Future.value();
    final withoutSlash = _path.substring(0, _path.length - 1);
    final slash = withoutSlash.lastIndexOf('/');
    return _load(slash == -1 ? '' : withoutSlash.substring(0, slash + 1));
  }

  Future<void> createFolder(String name) async {
    final clean = name.trim();
    if (clean.isEmpty || clean.contains('/') || clean.contains('..')) {
      throw ArgumentError('Invalid folder name');
    }
    final target = '$_path$clean/';
    await _transport.mkdirAll(target);
    await _load(target);
  }

  Future<void> _load(String path) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final entries = await _transport.readDir(path.isEmpty ? '/' : path);
      _folders =
          entries.where((e) => e.isDir).map((e) => e.name).toList()..sort();
      _path = path;
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
