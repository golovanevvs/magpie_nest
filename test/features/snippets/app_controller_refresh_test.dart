import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

class _FakeFolderRepository implements IFolderRepository {
  final List<Folder> folders;
  _FakeFolderRepository(this.folders);

  @override
  Future<List<Folder>> getAllFolders() async => List.of(folders);

  @override
  Future<List<String>> getDescendantIds(String id) async => [];

  @override
  Future<Folder?> getFolderById(String id) async {
    for (final folder in folders) {
      if (folder.id == id) return folder;
    }
    return null;
  }

  @override
  Future<void> saveFolder(Folder folder) async {}

  @override
  Future<void> deleteFolder(String id) async {}
}

class _FakeSnippetRepository implements ISnippetRepository {
  final List<Snippet> snippets;
  _FakeSnippetRepository(this.snippets);

  @override
  Future<List<Snippet>> getAllSnippets() async => List.of(snippets);

  @override
  Future<Snippet?> getSnippetById(String id) async {
    for (final snippet in snippets) {
      if (snippet.id == id) return snippet;
    }
    return null;
  }

  @override
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId) async {
    return snippets.where((s) => s.folderId == folderId).toList();
  }

  @override
  Future<List<Snippet>> getFavoriteSnippets() async {
    return snippets.where((s) => s.isFavorite).toList();
  }

  @override
  Future<List<Snippet>> getDeletedSnippets() async {
    return snippets.where((s) => s.isDeleted).toList();
  }

  @override
  Future<void> saveSnippet(Snippet snippet) async {}

  @override
  Future<void> deleteSnippet(String id) async {}

  @override
  Future<void> restoreSnippet(String id) async {}

  @override
  Future<void> permanentlyDeleteSnippet(String id) async {}

  @override
  Future<void> permanentlyDeleteDeletedSnippets() async {}
}

Folder _makeFolder(String id, String name) {
  final now = DateTime.now();
  return Folder(id: id, name: name, createdAt: now, updatedAt: now);
}

Snippet _makeSnippet(
  String id,
  String name, {
  String? folderId,
  bool isDeleted = false,
}) {
  final now = DateTime.now();
  return Snippet(
    id: id,
    name: name,
    fragments: [
      Fragment(
        id: 'f-$id',
        name: 'Frag $id',
        language: 'dart',
        content: 'void main() {}',
        updatedAt: now,
      ),
    ],
    folderId: folderId,
    isDeleted: isDeleted,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  AppController makeController(List<Folder> folders, List<Snippet> snippets) {
    return AppController(
      folderRepository: _FakeFolderRepository(folders),
      snippetRepository: _FakeSnippetRepository(snippets),
    );
  }

  test('refresh loads folders and snippets added remotely', () async {
    final folders = <Folder>[];
    final snippets = <Snippet>[];
    final controller = makeController(folders, snippets);

    await controller.initialize();
    expect(controller.folders, isEmpty);
    expect(controller.snippets, isEmpty);

    folders.add(_makeFolder('f-remote', 'Remote'));
    snippets.add(_makeSnippet('s-1', 'New snippet', folderId: 'f-remote'));

    await controller.refresh();

    expect(controller.folders.map((f) => f.id), contains('f-remote'));
    expect(controller.snippets.map((s) => s.id), contains('s-1'));
  });

  test('refresh preserves the selected folder and snippet', () async {
    final folders = [_makeFolder('f-work', 'Work')];
    final snippets = [_makeSnippet('s-1', 'Snippet 1', folderId: 'f-work')];
    final controller = makeController(folders, snippets);

    await controller.initialize();
    await controller.selectFolder(folders.first);
    controller.selectSnippet(snippets.first);
    expect(controller.selectedFolder?.id, 'f-work');
    expect(controller.selectedSnippet?.id, 's-1');

    folders.add(_makeFolder('f-remote', 'Remote'));
    snippets.add(_makeSnippet('s-2', 'Snippet 2', folderId: 'f-remote'));

    await controller.refresh();

    expect(controller.selectedFolder?.id, 'f-work');
    expect(controller.selectedSnippet?.id, 's-1');
    expect(controller.folders.map((f) => f.id), contains('f-remote'));
    expect(controller.snippets.map((s) => s.id), contains('s-1'));
  });

  test('refresh falls back to all snippets when the selected folder is gone', () async {
    final folders = [_makeFolder('f-work', 'Work')];
    final snippets = [_makeSnippet('s-1', 'Snippet 1', folderId: 'f-work')];
    final controller = makeController(folders, snippets);

    await controller.initialize();
    await controller.selectFolder(folders.first);
    controller.selectSnippet(snippets.first);

    folders.clear();
    snippets.clear();

    await controller.refresh();

    expect(controller.selectedFolder, isNull);
    expect(controller.selectedSnippet, isNull);
    expect(controller.folders, isEmpty);
    expect(controller.snippets, isEmpty);
    expect(controller.activeSection, SidebarSection.all);
  });
}