import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_list/snippet_list.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/snippet_preview.dart';
import 'package:material_ui/material_ui.dart';

class _FakeFolderRepository implements IFolderRepository {
  final List<Folder> folders;
  _FakeFolderRepository(this.folders);

  @override
  Future<List<Folder>> getAllFolders() async => folders;

  @override
  Future<List<String>> getDescendantIds(String id) async => [];

  @override
  Future<Folder?> getFolderById(String id) async =>
      folders.where((f) => f.id == id).firstOrNull;

  @override
  Future<void> saveFolder(Folder folder) async {}

  @override
  Future<void> deleteFolder(String id) async {}
}

class _FakeSnippetRepository implements ISnippetRepository {
  final List<Snippet> snippets;
  _FakeSnippetRepository(this.snippets);

  @override
  Future<List<Snippet>> getAllSnippets() async => snippets;

  @override
  Future<Snippet?> getSnippetById(String id) async =>
      snippets.where((s) => s.id == id).firstOrNull;

  @override
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId) async =>
      snippets.where((s) => s.folderId == folderId).toList();

  @override
  Future<List<Snippet>> getFavoriteSnippets() async =>
      snippets.where((s) => s.isFavorite).toList();

  @override
  Future<List<Snippet>> getDeletedSnippets() async =>
      snippets.where((s) => s.isDeleted).toList();

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

class _FakeSecureStorage implements SecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

Future<void> _passingTester(WebdavCredentials credentials) async {}

Snippet _makeSnippet() {
  final now = DateTime.now();
  return Snippet(
    id: 's1',
    name: 'My Snippet',
    fragments: [
      Fragment(
        id: 'f1',
        name: 'main',
        language: 'dart',
        content: 'void main() {}',
        updatedAt: now,
      ),
    ],
    folderId: null,
    createdAt: now,
    updatedAt: now,
  );
}

Future<AppController> _pumpCompact(WidgetTester tester) async {
  final now = DateTime.now();
  final controller = AppController(
    folderRepository: _FakeFolderRepository([
      Folder(id: '1', name: 'Work', createdAt: now, updatedAt: now),
      Folder(id: '2', name: 'Home', createdAt: now, updatedAt: now),
    ]),
    snippetRepository: _FakeSnippetRepository([_makeSnippet()]),
  );

  final cloud = CloudConnectionController(
    store: SecureWebdavCredentialsStore(_FakeSecureStorage()),
    tester: _passingTester,
  );
  final sync = SyncController(
    runner: () async {},
    cloud: cloud,
    purgeRunner: () async {},
  );

  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MainScreen(
        controller: controller,
        cloud: cloud,
        sync: sync,
        themeMode: ThemeMode.system,
        onThemeModeChanged: (_) {},
        currentLocale: const Locale('en'),
        onLocaleChanged: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets(
    'system back from the snippet preview returns to the list in compact layout',
    (tester) async {
      final controller = await _pumpCompact(tester);

      expect(controller.selectedSnippet, isNull);
      expect(find.byType(SnippetList), findsOneWidget);

      await tester.tap(find.text('My Snippet'));
      await tester.pumpAndSettle();

      expect(controller.selectedSnippet, isNotNull);
      expect(find.byType(SnippetPreview), findsOneWidget);
      expect(find.byType(SnippetList), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(controller.selectedSnippet, isNull);
      expect(find.byType(SnippetPreview), findsNothing);
      expect(find.byType(SnippetList), findsOneWidget);
      expect(find.byType(MainScreen), findsOneWidget);
    },
  );
}
