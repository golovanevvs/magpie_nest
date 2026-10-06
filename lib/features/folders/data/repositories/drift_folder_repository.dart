import 'package:drift/drift.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';

class DriftFolderRepository implements IFolderRepository {
  final AppDatabase db;

  DriftFolderRepository(this.db);

  @override
  Future<List<Folder>> getAllFolders() async {
    final rows =
        await (db.select(db.folders)
              ..where((table) => table.isDeleted.equals(false))
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();
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
  Future<List<String>> getDescendantIds(String id) async {
    final rows = await (db.select(
      db.folders,
    )..where((table) => table.isDeleted.equals(false))).get();

    final childrenByParent = <String, List<String>>{};
    for (final row in rows) {
      final parentId = row.parentId;
      if (parentId != null) {
        childrenByParent.putIfAbsent(parentId, () => []).add(row.id);
      }
    }

    final descendants = <String>[];
    final stack = [id];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      for (final child in childrenByParent[current] ?? const <String>[]) {
        descendants.add(child);
        stack.add(child);
      }
    }

    return descendants;
  }

  @override
  Future<void> deleteFolder(String id) async {
    final now = DateTime.now();
    final subtreeIds = [id, ...await getDescendantIds(id)];
    final rows = await (db.select(
      db.folders,
    )..where((t) => t.id.isIn(subtreeIds))).get();

    await db.transaction(() async {
      for (final row in rows) {
        await (db.update(
          db.folders,
        )..where((t) => t.id.equals(row.id))).write(
          FoldersCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(now),
            updatedAt: Value(now),
            revision: Value(row.revision + 1),
          ),
        );
      }
    });
  }

  Folder _toDomain(FolderRow row) {
    return Folder(
      id: row.id,
      name: row.name,
      parentId: row.parentId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      deletedAt: row.deletedAt,
      revision: row.revision,
    );
  }

  FolderRow _toRow(Folder folder) {
    return FolderRow(
      id: folder.id,
      name: folder.name,
      parentId: folder.parentId,
      sortOrder: folder.sortOrder,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
      isDeleted: folder.isDeleted,
      deletedAt: folder.deletedAt,
      revision: folder.revision,
    );
  }
}
