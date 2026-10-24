import 'package:flutter/foundation.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';

typedef SyncRunner = Future<void> Function();

class SyncController extends ChangeNotifier {
  final SyncRunner _runner;
  final CloudConnectionController _cloud;

  bool _syncing = false;
  String? _error;
  DateTime? _lastSyncedAt;

  SyncController({
    required this._runner,
    required this._cloud,
  });

  bool get syncing => _syncing;
  String? get error => _error;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get canSync => _cloud.isConnected && !_syncing;

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
}
