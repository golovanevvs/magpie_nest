import 'package:magpie_nest/core/sync/i_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';

class InMemorySyncRepository implements ISyncRepository {
  final List<_StoredBatch> _journal = [];
  int _nextCloudSeq = 1;

  @override
  Future<void> pushBatch(SyncBatch batch) async {
    _journal.add(_StoredBatch(cloudSeq: _nextCloudSeq++, batch: batch));
  }

  @override
  Future<List<SyncBatch>> fetchBatchesSince(int cloudSeq) async {
    return [
      for (final stored in _journal)
        if (stored.cloudSeq > cloudSeq)
          _withCloudSeq(stored.batch, stored.cloudSeq),
    ];
  }

  Iterable<SyncBatch> get pushed =>
      _journal.map((s) => _withCloudSeq(s.batch, s.cloudSeq));

  SyncBatch _withCloudSeq(SyncBatch batch, int cloudSeq) {
    return SyncBatch(
      batchId: batch.batchId,
      deviceId: batch.deviceId,
      cloudSeq: cloudSeq,
      createdAt: batch.createdAt,
      changes: batch.changes,
    );
  }
}

class _StoredBatch {
  final int cloudSeq;
  final SyncBatch batch;

  const _StoredBatch({required this.cloudSeq, required this.batch});
}
