import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folder_tree.dart';
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

Future<AppController> makeController() async {
  final now = DateTime.now();
  final controller = AppController(
    folderRepository: _FakeFolderRepository([
      Folder(id: '1', name: 'Work', createdAt: now, updatedAt: now),
      Folder(id: '2', name: 'Home', createdAt: now, updatedAt: now),
    ]),
    snippetRepository: _FakeSnippetRepository(),
  );
  await controller.foldersController.loadFolders();
  return controller;
}

Widget host(AppController controller) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: FolderTree(
        controller: controller,
        searchQuery: '',
        onFinishEditing: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows a Fluent MenuFlyout on right-click (Windows)', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final controller = await makeController();
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work'), buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();

    expect(find.byType(fluent.MenuFlyout), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    // New folder, Rename, Delete, Set icon, Default language = 5 items.
    expect(find.text(l10n.contextMenuNewFolder), findsOneWidget);
    expect(find.text(l10n.contextMenuRename), findsOneWidget);
    expect(find.text(l10n.buttonDelete), findsOneWidget);
    expect(find.text(l10n.contextMenuSetIcon), findsOneWidget);
    expect(find.text(l10n.contextMenuDefaultLanguage), findsOneWidget);
  });

  testWidgets('shows a Material popup on right-click (Android)', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final controller = await makeController();
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work'), buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();

    expect(find.byType(fluent.MenuFlyout), findsNothing);
    expect(
      find.text(
        AppLocalizations.of(
          tester.element(find.byType(Scaffold)),
        )!.contextMenuNewFolder,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Delete closes the Fluent menu and shows confirmation', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final controller = await makeController();
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work'), buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
    expect(find.byType(fluent.MenuFlyout), findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    await tester.tap(find.text(l10n.buttonDelete));
    await tester.pumpAndSettle();

    expect(find.byType(fluent.MenuFlyout), findsNothing);
    expect(find.text(l10n.dialogDeleteFolderTitle), findsOneWidget);
  });
}
