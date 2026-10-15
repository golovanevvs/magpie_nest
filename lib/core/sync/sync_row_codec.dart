import 'package:drift/drift.dart';
import 'package:magpie_nest/core/database/app_database.dart';

Map<String, Object?> folderToPayload(FolderRow row) {
  return {
    'id': row.id,
    'name': row.name,
    'parentId': row.parentId,
    'sortOrder': row.sortOrder,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
    'isDeleted': row.isDeleted,
    'deletedAt': _dateTimeToIso(row.deletedAt),
    'revision': row.revision,
  };
}

FoldersCompanion folderFromPayload(Map<String, Object?> row) {
  return FoldersCompanion.insert(
    id: row['id']! as String,
    name: row['name']! as String,
    parentId: Value(row['parentId'] as String?),
    sortOrder: Value(row['sortOrder']! as int),
    createdAt: _isoToDateTime(row['createdAt']),
    updatedAt: _isoToDateTime(row['updatedAt']),
    isDeleted: Value(row['isDeleted']! as bool),
    deletedAt: Value(_isoToDateTimeOrNull(row['deletedAt'])),
    revision: Value(row['revision']! as int),
  );
}

Map<String, Object?> snippetToPayload(SnippetRow row) {
  return {
    'id': row.id,
    'name': row.name,
    'description': row.description,
    'activeFragmentId': row.activeFragmentId,
    'folderId': row.folderId,
    'isFavorite': row.isFavorite,
    'isDeleted': row.isDeleted,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
    'revision': row.revision,
    'deletedAt': _dateTimeToIso(row.deletedAt),
  };
}

SnippetsCompanion snippetFromPayload(Map<String, Object?> row) {
  return SnippetsCompanion.insert(
    id: row['id']! as String,
    name: row['name']! as String,
    description: Value(row['description'] as String?),
    activeFragmentId: Value(row['activeFragmentId'] as String?),
    folderId: Value(row['folderId'] as String?),
    isFavorite: Value(row['isFavorite']! as bool),
    isDeleted: Value(row['isDeleted']! as bool),
    createdAt: _isoToDateTime(row['createdAt']),
    updatedAt: _isoToDateTime(row['updatedAt']),
    revision: Value(row['revision']! as int),
    deletedAt: Value(_isoToDateTimeOrNull(row['deletedAt'])),
  );
}

Map<String, Object?> fragmentToPayload(FragmentRow row) {
  return {
    'id': row.id,
    'snippetId': row.snippetId,
    'name': row.name,
    'language': row.language,
    'content': row.content,
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
    'sortOrder': row.sortOrder,
    'revision': row.revision,
    'isDeleted': row.isDeleted,
    'deletedAt': _dateTimeToIso(row.deletedAt),
  };
}

FragmentsCompanion fragmentFromPayload(Map<String, Object?> row) {
  return FragmentsCompanion.insert(
    id: row['id']! as String,
    snippetId: row['snippetId']! as String,
    name: row['name']! as String,
    language: row['language']! as String,
    content: row['content']! as String,
    updatedAt: _isoToDateTime(row['updatedAt']),
    sortOrder: Value(row['sortOrder']! as int),
    revision: Value(row['revision']! as int),
    isDeleted: Value(row['isDeleted']! as bool),
    deletedAt: Value(_isoToDateTimeOrNull(row['deletedAt'])),
  );
}

String? _dateTimeToIso(DateTime? value) => value?.toUtc().toIso8601String();

DateTime _isoToDateTime(Object? value) => DateTime.parse(value! as String);

DateTime? _isoToDateTimeOrNull(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
