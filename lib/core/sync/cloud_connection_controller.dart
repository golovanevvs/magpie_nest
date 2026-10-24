import 'package:flutter/foundation.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';

typedef CloudConnectionTester =
    Future<void> Function(WebdavCredentials credentials);

enum CloudConnectionStatus { notConfigured, connected }

class CloudConnectionController extends ChangeNotifier {
  final WebdavCredentialsStore _store;
  final CloudConnectionTester _tester;

  CloudConnectionStatus _status = CloudConnectionStatus.notConfigured;
  String? _connectedUrl;
  String? _connectedFolder;
  bool _busy = false;
  String? _error;

  CloudConnectionController({
    required this._store,
    CloudConnectionTester? tester,
  }) : _tester = tester ?? _webdavTester;

  CloudConnectionStatus get status => _status;
  bool get isConnected => _status == CloudConnectionStatus.connected;
  String? get connectedUrl => _connectedUrl;
  String? get connectedFolder => _connectedFolder;
  bool get busy => _busy;
  String? get error => _error;

  Future<void> load() async {
    _applyCredentials(await _store.read());
    notifyListeners();
  }

  Future<bool> testConnection(WebdavCredentials credentials) =>
      _run(credentials, save: false);

  Future<bool> connect(WebdavCredentials credentials) =>
      _run(credentials, save: true);

  Future<void> disconnect() async {
    await _store.clear();
    _applyCredentials(null);
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(WebdavCredentials credentials, {required bool save}) async {
    if (!credentials.isConfigured) return false;

    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _tester(credentials);
      if (save) {
        await _store.save(credentials);
        _applyCredentials(credentials);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _applyCredentials(WebdavCredentials? credentials) {
    if (credentials == null) {
      _status = CloudConnectionStatus.notConfigured;
      _connectedUrl = null;
      _connectedFolder = null;
    } else {
      _status = CloudConnectionStatus.connected;
      _connectedUrl = credentials.url;
      _connectedFolder = credentials.folder;
    }
  }

  static Future<void> _webdavTester(WebdavCredentials credentials) async {
    final transport = webdavTransportFrom(credentials);
    await transport.readProps('/').timeout(const Duration(seconds: 15));
  }
}
