import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_device.dart';

abstract interface class ISyncRepository {
  Future<void> pushBatch(SyncBatch batch);
  Future<List<JournalEntry>> fetchAfter(String? cursor);
  Future<void> clearRemote();
  Future<void> upsertDevice(SyncDeviceInfo device);
  Future<List<SyncDeviceInfo>> listDevices();
  Future<void> deleteJournalBefore(String fileName);
}
