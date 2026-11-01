import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/sync/sync_row_codec.dart';

void _expectSameMoment(DateTime? actual, DateTime? expected) {
  if (expected == null) {
    expect(actual, isNull);
    return;
  }
  expect(actual, isNotNull);
  expect(actual!.isAtSameMomentAs(expected), isTrue);
}

void main() {
  final t1 = DateTime(2026, 1, 1, 10, 0);
  final t2 = DateTime(2026, 1, 2, 12, 30);

  group('folder codec', () {
    test('roundtrip preserves every field', () {
      final row = FolderRow(
        id: 'f1',
        name: 'Work',
        sortOrder: 3,
        createdAt: t1,
        updatedAt: t2,
        isDeleted: false,
        deletedAt: null,
        revision: 5,
      );

      final c = folderFromPayload(folderToPayload(row));

      expect(c.id.value, row.id);
      expect(c.name.value, row.name);
      expect(c.parentId.value, row.parentId);
      expect(c.sortOrder.value, row.sortOrder);
      _expectSameMoment(c.createdAt.value, row.createdAt);
      _expectSameMoment(c.updatedAt.value, row.updatedAt);
      expect(c.isDeleted.value, row.isDeleted);
      _expectSameMoment(c.deletedAt.value, row.deletedAt);
      expect(c.revision.value, row.revision);
    });

    test('nullable fields survive as null', () {
      final row = FolderRow(
        id: 'f2',
        name: 'Root',
        parentId: null,
        sortOrder: 0,
        createdAt: t1,
        updatedAt: t1,
        isDeleted: false,
        deletedAt: null,
        revision: 0,
      );
      final c = folderFromPayload(folderToPayload(row));
      expect(c.parentId.value, isNull);
      _expectSameMoment(c.deletedAt.value, row.deletedAt);
    });
  });

  group('snippet codec', () {
    test('roundtrip preserves every field', () {
      final row = SnippetRow(
        id: 's1',
        name: 'Hello',
        description: 'A demo snippet',
        activeFragmentId: 'frag-1',
        folderId: 'f1',
        isFavorite: true,
        isDeleted: false,
        createdAt: t1,
        updatedAt: t2,
        revision: 7,
        deletedAt: null,
      );

      final c = snippetFromPayload(snippetToPayload(row));

      expect(c.id.value, row.id);
      expect(c.name.value, row.name);
      expect(c.description.value, row.description);
      expect(c.activeFragmentId.value, row.activeFragmentId);
      expect(c.folderId.value, row.folderId);
      expect(c.isFavorite.value, row.isFavorite);
      expect(c.isDeleted.value, row.isDeleted);
      _expectSameMoment(c.createdAt.value, row.createdAt);
      _expectSameMoment(c.updatedAt.value, row.updatedAt);
      expect(c.revision.value, row.revision);
      _expectSameMoment(c.deletedAt.value, row.deletedAt);
    });

    test('nullable fields survive as null', () {
      final row = SnippetRow(
        id: 's2',
        name: 'Root snippet',
        description: null,
        activeFragmentId: null,
        folderId: null,
        isFavorite: false,
        isDeleted: false,
        createdAt: t1,
        updatedAt: t1,
        revision: 0,
        deletedAt: null,
      );
      final c = snippetFromPayload(snippetToPayload(row));
      expect(c.description.value, isNull);
      expect(c.activeFragmentId.value, isNull);
      expect(c.folderId.value, isNull);
      _expectSameMoment(c.deletedAt.value, null);
    });

    test('tombstone fields survive', () {
      final row = SnippetRow(
        id: 's3',
        name: 'Trashed',
        description: null,
        activeFragmentId: null,
        folderId: null,
        isFavorite: false,
        isDeleted: true,
        createdAt: t1,
        updatedAt: t2,
        revision: 2,
        deletedAt: t2,
      );
      final c = snippetFromPayload(snippetToPayload(row));
      expect(c.isDeleted.value, isTrue);
      _expectSameMoment(c.deletedAt.value, t2);
    });
  });

  group('fragment codec', () {
    test('roundtrip preserves every field including snippetId', () {
      final row = FragmentRow(
        id: 'frag-1',
        snippetId: 's1',
        name: 'main',
        language: 'dart',
        content: 'void main() {}',
        updatedAt: t2,
        sortOrder: 0,
        revision: 3,
        isDeleted: false,
        deletedAt: null,
      );

      final c = fragmentFromPayload(fragmentToPayload(row));

      expect(c.id.value, row.id);
      expect(c.snippetId.value, row.snippetId);
      expect(c.name.value, row.name);
      expect(c.language.value, row.language);
      expect(c.content.value, row.content);
      _expectSameMoment(c.updatedAt.value, row.updatedAt);
      expect(c.sortOrder.value, row.sortOrder);
      expect(c.revision.value, row.revision);
      expect(c.isDeleted.value, row.isDeleted);
      _expectSameMoment(c.deletedAt.value, row.deletedAt);
    });
  });
}
