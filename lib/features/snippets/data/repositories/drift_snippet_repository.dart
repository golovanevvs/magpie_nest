import 'package:drift/drift.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';

class DriftSnippetRepository implements ISnippetRepository {
  final AppDatabase db;

  DriftSnippetRepository(this.db);

  @override
  Future<List<Snippet>> getAllSnippets() async {
    final snippetRows = await (db.select(db.snippets)).get();
    return _withFragments(snippetRows);
  }

  @override
  Future<Snippet?> getSnippetById(String id) async {
    final row = await (db.select(
      db.snippets,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final rows = await _withFragments([row]);
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId) async {
    final query = db.select(db.snippets)
      ..where((table) {
        if (folderId == null) {
          return table.folderId.isNull();
        }
        return table.folderId.equals(folderId);
      });
    return _withFragments(await query.get());
  }

  @override
  Future<List<Snippet>> getFavoriteSnippets() async {
    final rows = await (db.select(
      db.snippets,
    )..where((table) => table.isFavorite.equals(true))).get();
    return _withFragments(rows);
  }

  @override
  Future<List<Snippet>> getDeletedSnippets() async {
    final rows = await (db.select(
      db.snippets,
    )..where((table) => table.isDeleted.equals(true))).get();
    return _withFragments(rows);
  }

  @override
  Future<void> saveSnippet(Snippet snippet) async {
    await db.transaction(() async {
      await db.into(db.snippets).insertOnConflictUpdate(_snippetToRow(snippet));

      final existing = await (db.select(
        db.fragments,
      )..where((table) => table.snippetId.equals(snippet.id))).get();
      final keepIds = snippet.fragments.map((f) => f.id).toSet();

      for (final fragmentRow in existing) {
        if (!keepIds.contains(fragmentRow.id)) {
          await (db.delete(
            db.fragments,
          )..where((table) => table.id.equals(fragmentRow.id))).go();
        }
      }

      for (var i = 0; i < snippet.fragments.length; i++) {
        final fragment = snippet.fragments[i];
        await db
            .into(db.fragments)
            .insertOnConflictUpdate(_fragmentToRow(snippet.id, fragment, i));
      }
    });
  }

  @override
  Future<void> deleteSnippet(String id) async {
    await (db.update(db.snippets)..where((table) => table.id.equals(id))).write(
      SnippetsCompanion(isDeleted: const Value(true)),
    );
  }

  @override
  Future<void> restoreSnippet(String id) async {
    await (db.update(db.snippets)..where((table) => table.id.equals(id))).write(
      SnippetsCompanion(isDeleted: const Value(false)),
    );
  }

  @override
  Future<void> permanentlyDeleteSnippet(String id) async {
    await (db.delete(db.snippets)..where((table) => table.id.equals(id))).go();
  }

  @override
  Future<void> permanentlyDeleteDeletedSnippets() async {
    await (db.delete(
      db.snippets,
    )..where((table) => table.isDeleted.equals(true))).go();
  }

  // helpers

  Future<List<Snippet>> _withFragments(List<SnippetRow> snippetRows) async {
    if (snippetRows.isEmpty) return [];

    final ids = snippetRows.map((r) => r.id).toList();
    final fragmentRows =
        await (db.select(db.fragments)
              ..where((table) => table.snippetId.isIn(ids))
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();

    final bySnippet = <String, List<FragmentRow>>{};
    for (final fragmentRow in fragmentRows) {
      bySnippet.putIfAbsent(fragmentRow.snippetId, () => []).add(fragmentRow);
    }

    return snippetRows
        .map((row) => _snippetToDomain(row, bySnippet[row.id] ?? const []))
        .toList();
  }

  Snippet _snippetToDomain(SnippetRow row, List<FragmentRow> fragmentRows) {
    return Snippet(
      id: row.id,
      name: row.name,
      description: row.description,
      fragments: fragmentRows.map(_fragmentToDomain).toList(),
      activeFragmentId: row.activeFragmentId,
      folderId: row.folderId,
      isFavorite: row.isFavorite,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Fragment _fragmentToDomain(FragmentRow row) {
    return Fragment(
      id: row.id,
      name: row.name,
      language: row.language,
      content: row.content,
    );
  }

  SnippetRow _snippetToRow(Snippet snippet) {
    return SnippetRow(
      id: snippet.id,
      name: snippet.name,
      description: snippet.description,
      activeFragmentId: snippet.activeFragmentId,
      folderId: snippet.folderId,
      isFavorite: snippet.isFavorite,
      isDeleted: snippet.isDeleted,
      createdAt: snippet.createdAt,
      updatedAt: snippet.updatedAt,
    );
  }

  FragmentRow _fragmentToRow(String snippetId, Fragment fragment, int index) {
    return FragmentRow(
      id: fragment.id,
      snippetId: snippetId,
      name: fragment.name,
      language: fragment.language,
      content: fragment.content,
      sortOrder: index,
    );
  }
}
