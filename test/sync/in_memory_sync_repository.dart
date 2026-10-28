import 'package:magpie_nest/core/sync/i_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_device.dart';

class InMemorySyncRepository implements ISyncRepository {
  final List<JournalEntry> _journal = [];
  final Map<String, SyncDeviceInfo> _devices = {};

  @override
  Future<void> pushBatch(SyncBatch batch) async {
    _journal.add(JournalEntry(file: _fileNameFor(batch), batch: batch));
    _journal.sort((a, b) => a.file.compareTo(b.file));
  }

  @override
  Future<List<JournalEntry>> fetchAfter(String? cursor) async {
    return [
      for (final entry in _journal)
        if (cursor == null || entry.file.compareTo(cursor) > 0) entry,
    ];
  }

  @override
  Future<void> clearRemote() async {
    _journal.clear();
    _devices.clear();
  }

  @override
  Future<void> upsertDevice(SyncDeviceInfo device) async =>
      _devices[device.deviceId] = device;

  @override
  Future<List<SyncDeviceInfo>> listDevices() async =>
      _devices.values.toList(growable: false);

  @override
  Future<void> deleteJournalBefore(String fileName) async {
    _journal.removeWhere((entry) => entry.file.compareTo(fileName) <= 0);
  }

  Iterable<JournalEntry> get pushed => _journal;

  Iterable<SyncDeviceInfo> get devices => _devices.values;

  String _fileNameFor(SyncBatch batch) {
    final ts = batch.createdAt.toUtc().toIso8601String().replaceAll(':', '-');
    return '$ts-${batch.batchId}.json';
  }
}
