import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/sidebar.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folder_tree.dart';
import 'package:material_ui/material_ui.dart';

const double _keyboardInset = 300;
const Size _surfaceSize = Size(360, 800);

class _FakeFolderRepository implements IFolderRepository {
  final List<Folder> folders;
  _FakeFolderRepository(this.folders);

  @override
  Future<List<Folder>> getAllFolders() async => folders;

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

Future<AppController> _makeController({int folderCount = 0}) async {
  final now = DateTime.now();
  final folders = List<Folder>.generate(
    folderCount,
    (index) => Folder(
      id: 'folder-$index',
      name: 'Folder ${index + 1}',
      sortOrder: index,
      createdAt: now,
      updatedAt: now,
    ),
  );
  final controller = AppController(
    folderRepository: _FakeFolderRepository(folders),
    snippetRepository: _FakeSnippetRepository(),
  );
  await controller.foldersController.loadFolders();
  return controller;
}

Widget _hostFolderTree(AppController controller, {String? editingFolderId}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 280,
          height: 300,
          child: FolderTree(
            controller: controller,
            searchQuery: '',
            editingFolderId: editingFolderId,
            onFinishEditing: () {},
          ),
        ),
      ),
    ),
  );
}

Widget _hostSidebar(AppController controller) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(viewInsets: const EdgeInsets.only(bottom: _keyboardInset)),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Sidebar(controller: controller),
        ),
      ),
    ),
  );
}

void _useAndroid() {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
}

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = _surfaceSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpScrollAnimation(WidgetTester tester) async {
  for (var frame = 0; frame < 15; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
    'scrolls the edit field into view when it starts below the viewport',
    (tester) async {
      _useAndroid();
      final controller = await _makeController(folderCount: 30);
      final lastFolderId = controller.folders.last.id;

      await tester.pumpWidget(_hostFolderTree(controller));
      await tester.pumpAndSettle();

      expect(find.byType(FolderEditField), findsNothing);
      expect(find.text('Folder 30'), findsNothing);

      await tester.pumpWidget(
        _hostFolderTree(controller, editingFolderId: lastFolderId),
      );
      await _pumpScrollAnimation(tester);

      final field = find.byType(FolderEditField);
      expect(field, findsOneWidget);

      final treeRect = tester.getRect(find.byType(ListView));
      final fieldRect = tester.getRect(field);
      expect(fieldRect.top, greaterThanOrEqualTo(treeRect.top - 0.5));
      expect(fieldRect.bottom, lessThanOrEqualTo(treeRect.bottom + 0.5));
    },
  );

  testWidgets('shrinks the sidebar content by the keyboard inset', (
    tester,
  ) async {
    _useAndroid();
    _usePhoneSurface(tester);
    final controller = await _makeController();

    await tester.pumpWidget(_hostSidebar(controller));
    await tester.pumpAndSettle();

    final treeRect = tester.getRect(find.byType(FolderTree));
    expect(treeRect.bottom, closeTo(_surfaceSize.height - _keyboardInset, 1));
  });

  testWidgets('keeps the new folder edit field above the keyboard', (
    tester,
  ) async {
    _useAndroid();
    _usePhoneSurface(tester);
    final controller = await _makeController(folderCount: 30);

    await tester.pumpWidget(_hostSidebar(controller));
    await tester.pumpAndSettle();

    expect(find.byType(FolderEditField), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await _pumpScrollAnimation(tester);

    expect(controller.folders.length, 31);

    final field = find.byType(FolderEditField);
    expect(field, findsOneWidget);

    final treeRect = tester.getRect(find.byType(FolderTree));
    final fieldRect = tester.getRect(field);
    expect(fieldRect.top, greaterThanOrEqualTo(treeRect.top - 0.5));
    expect(fieldRect.bottom, lessThanOrEqualTo(treeRect.bottom + 0.5));
    expect(
      fieldRect.bottom,
      lessThanOrEqualTo(_surfaceSize.height - _keyboardInset + 0.5),
    );
  });
}
