import 'dart:convert';
import 'dart:typed_data';

import 'package:magpie_nest/core/sync/i_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/sync_batch_codec.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';

class WebdavSyncRepository implements ISyncRepository {
  final WebdavTransport transport;
  final String journalDir;

  WebdavSyncRepository({
    required this.transport,
    this.journalDir = kDefaultJournalDir,
  }) {
    if (!_nonRootDir(journalDir)) {
      throw StateError('Sync folder must have a subfolder (got "$journalDir")');
    }
  }

  String _fileName(SyncBatch batch) {
    final ts = batch.createdAt.toUtc().toIso8601String().replaceAll(':', '-');
    return '$journalDir$ts-${batch.batchId}.json';
  }

  @override
  Future<void> pushBatch(SyncBatch batch) async {
    await transport.mkdirAll(journalDir);
    final bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(syncBatchToJson(batch))),
    );
    await transport.write(
      _fileName(batch),
      bytes,
      headers: {'If-None-Match': '*'},
    );
  }

  @override
  Future<List<JournalEntry>> fetchAfter(String? cursor) async {
    final List<WebdavFile> entries;
    try {
      entries = await transport.readDir(journalDir);
    } on WebdavException catch (e) {
      if (e.statusCode == 404) return const [];
      rethrow;
    }
    final files = entries.where((e) => !e.isDir).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final journalEntries = <JournalEntry>[];
    for (final f in files) {
      if (cursor != null && f.name.compareTo(cursor) <= 0) continue;
      final json = jsonDecode(utf8.decode(await transport.read(f.path))) as Map;
      journalEntries.add(
        JournalEntry(
          file: f.name,
          batch: syncBatchFromJson(Map<String, Object?>.from(json)),
        ),
      );
    }
    return journalEntries;
  }

  @override
  Future<void> clearRemote() async {
    if (!_nonRootDir(journalDir)) {
      throw StateError(
        'Refusing to clear remote: the sync folder must have a subfolder '
        '(got "$journalDir")',
      );
    }
    try {
      final entries = await transport.readDir(journalDir);
      for (final f in entries.where((e) => !e.isDir)) {
        await transport.remove(f.path);
      }
    } on WebdavException catch (e) {
      if (e.statusCode != 404) rethrow;
      return;
    }
    try {
      await transport.remove(journalDir);
    } on WebdavException catch (e) {
      if (e.statusCode != 404) rethrow;
    }
  }

  static bool _nonRootDir(String dir) {
    final d = dir.replaceAll(RegExp(r'^/+|/+$'), '');
    return d.isNotEmpty;
  }
}
