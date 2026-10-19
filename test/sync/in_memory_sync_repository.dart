import 'package:magpie_nest/core/sync/i_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';

class InMemorySyncRepository implements ISyncRepository {
  final List<JournalEntry> _journal = [];
  int _nextFile = 1;

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

  Iterable<JournalEntry> get pushed => _journal;

  String _fileNameFor(SyncBatch batch) {
    final counter = _nextFile.toString().padLeft(12, '0');
    _nextFile++;
    return 'journal/$counter-${batch.batchId}.json';
  }
}
