import 'package:flutter/foundation.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';

typedef SyncRunner = Future<void> Function();

class SyncController extends ChangeNotifier {
  final SyncRunner _runner;
  final SyncRunner _purger;
  final CloudConnectionController _cloud;

  bool _syncing = false;
  bool _purging = false;
  String? _error;
  DateTime? _lastSyncedAt;

  SyncController({
    required this._runner,
    required this._cloud,
    SyncRunner? purgeRunner,
  }) : _purger = purgeRunner ?? _defaultPurge;

  bool get syncing => _syncing;
  bool get purging => _purging;
  String? get error => _error;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get canSync => _cloud.isConnected && !_syncing && !_purging;

  static Future<void> _defaultPurge() =>
      throw StateError('purgeRunner is not configured');

  Future<bool> syncNow() async {
    if (!canSync) return false;

    _syncing = true;
    _error = null;
    notifyListeners();
    try {
      await _runner();
      _lastSyncedAt = DateTime.now();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<bool> purgeRemote() async {
    if (!_cloud.isConnected || _purging) return false;

    _purging = true;
    _error = null;
    notifyListeners();
    try {
      await _purger();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _purging = false;
      notifyListeners();
    }
  }
}
