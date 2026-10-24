import 'package:magpie_nest/core/sync/i_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_batch.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/core/sync/webdav_sync_repository.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';

class LazyWebdavSyncRepository implements ISyncRepository {
  final WebdavCredentialsStore _store;
  final WebdavTransport Function(WebdavCredentials) _transportFactory;

  LazyWebdavSyncRepository({
    required this._store,
    WebdavTransport Function(WebdavCredentials)? transportFactory,
  }) : _transportFactory = transportFactory ?? webdavTransportFrom;

  @override
  Future<void> pushBatch(SyncBatch batch) async =>
      (await _repository()).pushBatch(batch);

  @override
  Future<List<JournalEntry>> fetchAfter(String? cursor) async =>
      (await _repository()).fetchAfter(cursor);

  Future<WebdavSyncRepository> _repository() async {
    final credentials = await _store.read();
    if (credentials == null) throw StateError('Cloud is not configured');
    return WebdavSyncRepository(
      transport: _transportFactory(credentials),
      journalDir: credentials.folder,
    );
  }
}
