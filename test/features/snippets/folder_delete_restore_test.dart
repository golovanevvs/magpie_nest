import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/features/folders/data/repositories/drift_folder_repository.dart';
import 'package:magpie_nest/features/snippets/data/repositories/drift_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

void main() {
  late AppDatabase db;
  late AppController controller;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    controller = AppController(
      folderRepository: DriftFolderRepository(db),
      snippetRepository: DriftSnippetRepository(db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  String? createdFolderId;

  Future<void> createFolderWithSnippet() async {
    await controller.initialize();
    final folder = await controller.createFolder('Folder');
    createdFolderId = folder.id;
    final now = DateTime.now();
    await controller.selectFolder(folder);
    await controller.createSnippet(
      Snippet(
        id: 'snippet-1',
        name: 'Snippet 1',
        fragments: [
          Fragment(
            id: 'fragment-1',
            name: 'Fragment 1',
            language: 'dart',
            content: 'void main() {}',
            updatedAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  test('restored snippet from deleted folder appears in inbox', () async {
    await createFolderWithSnippet();

    await controller.deleteFolder(createdFolderId!);
    await controller.selectSection(SidebarSection.trash);
    expect(controller.snippets.map((s) => s.id), contains('snippet-1'));

    await controller.restoreSnippet('snippet-1');

    final row = await (db.select(
      db.snippets,
    )..where((t) => t.id.equals('snippet-1'))).getSingleOrNull();
    expect(row!.isDeleted, false);
    expect(row.folderId, isNull);

    await controller.selectSection(SidebarSection.inbox);
    expect(controller.snippets.map((s) => s.id), contains('snippet-1'));
  });

  test('permanently deleted snippet is gone everywhere', () async {
    await createFolderWithSnippet();

    await controller.deleteFolder(createdFolderId!);
    await controller.permanentlyDeleteSnippet('snippet-1');

    final row = await (db.select(
      db.snippets,
    )..where((t) => t.id.equals('snippet-1'))).getSingleOrNull();
    expect(row, isNull);

    await controller.selectSection(SidebarSection.all);
    expect(controller.snippets.map((s) => s.id), isNot(contains('snippet-1')));

    await controller.selectSection(SidebarSection.inbox);
    expect(controller.snippets.map((s) => s.id), isNot(contains('snippet-1')));
  });
}