import 'package:drift/drift.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';

class DriftFolderRepository implements IFolderRepository {
  final AppDatabase db;

  DriftFolderRepository(this.db);

  @override
  Future<List<Folder>> getAllFolders() async {
    final rows = await (db.select(
      db.folders,
    )..orderBy([(table) => OrderingTerm.asc(table.sortOrder)])).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Folder?> getFolderById(String id) async {
    final row = await (db.select(
      db.folders,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    await db.into(db.folders).insertOnConflictUpdate(_toRow(folder));
  }

  @override
  Future<void> deleteFolder(String id) async {
    await (db.delete(
      db.folders,
    )..where((table) => table.id.equals(id) | table.parentId.equals(id))).go();
  }

  Folder _toDomain(FolderRow row) {
    return Folder(
      id: row.id,
      name: row.name,
      parentId: row.parentId,
      sortOrder: row.sortOrder,
    );
  }

  FolderRow _toRow(Folder folder) {
    return FolderRow(
      id: folder.id,
      name: folder.name,
      parentId: folder.parentId,
      sortOrder: folder.sortOrder,
    );
  }
}
