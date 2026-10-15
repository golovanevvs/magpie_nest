import 'package:magpie_nest/core/sync/sync_batch.dart';

abstract interface class ISyncRepository {
  Future<void> pushBatch(SyncBatch batch);
  Future<List<SyncBatch>> fetchBatchesSince(int cloudSeq);
}
