import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';
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
  @override
  Future<List<Snippet>> getAllSnippets() async => [];

  @override
  Future<Snippet?> getSnippetById(String id) async => null;

  @override
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId) async => [];

  @override
  Future<List<Snippet>> getFavoriteSnippets() async => [];

  @override
  Future<List<Snippet>> getDeletedSnippets() async => [];

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

Future<AppController> _makeController() async {
  final now = DateTime.now();
  return AppController(
    folderRepository: _FakeFolderRepository([
      Folder(id: '1', name: 'Work', createdAt: now, updatedAt: now),
      Folder(id: '2', name: 'Home', createdAt: now, updatedAt: now),
    ]),
    snippetRepository: _FakeSnippetRepository(),
  );
}

Future<void> _pumpMainScreen(WidgetTester tester) async {
  final controller = await _makeController();
  final cloud = CloudConnectionController(
    store: SecureWebdavCredentialsStore(_FakeSecureStorage()),
    tester: _passingTester,
  );
  final sync = SyncController(
    runner: () async {},
    cloud: cloud,
    purgeRunner: () async {},
  );

  tester.view.physicalSize = const Size(700, 900);
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
}

void main() {
  testWidgets('opens the drawer from the menu button in medium layout', (
    tester,
  ) async {
    await _pumpMainScreen(tester);

    final scaffold =
        tester.state<ScaffoldState>(find.byType(Scaffold).first);
    expect(scaffold.isDrawerOpen, isFalse);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(scaffold.isDrawerOpen, isTrue);
  });

  testWidgets('tapping a folder closes the responsive drawer', (tester) async {
    await _pumpMainScreen(tester);

    final scaffold =
        tester.state<ScaffoldState>(find.byType(Scaffold).first);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isTrue);

    await tester.tap(find.text('Work'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(scaffold.isDrawerOpen, isFalse);
  });

  testWidgets('tapping a library item closes the responsive drawer', (
    tester,
  ) async {
    await _pumpMainScreen(tester);

    final scaffold =
        tester.state<ScaffoldState>(find.byType(Scaffold).first);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isTrue);

    await tester.tap(find.text('All Snippets'));
    await tester.pumpAndSettle();

    expect(scaffold.isDrawerOpen, isFalse);
  });
}