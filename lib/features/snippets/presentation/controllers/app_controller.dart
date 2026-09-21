import 'package:flutter/foundation.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/folders_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/fragments_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/sidebar_section.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/snippets_controller.dart';

export 'package:magpie_nest/features/snippets/presentation/controllers/sidebar_section.dart';

class AppController extends ChangeNotifier {
  final IFolderRepository folderRepository;
  final ISnippetRepository snippetRepository;

  final FoldersController foldersController;
  final SnippetsController snippetsController;
  late final FragmentsController fragmentsController;

  AppController({
    required this.folderRepository,
    required this.snippetRepository,
  }) : foldersController = FoldersController(
         folderRepository: folderRepository,
       ),
       snippetsController = SnippetsController(
         snippetRepository: snippetRepository,
       ) {
    fragmentsController = FragmentsController(
      snippetRepository: snippetRepository,
      snippetsController: snippetsController,
    );

    foldersController.addListener(notifyListeners);
    snippetsController.addListener(notifyListeners);
  }

  List<Snippet> get snippets => snippetsController.snippets;
  Snippet? get selectedSnippet => snippetsController.selectedSnippet;
  List<Folder> get folders => foldersController.folders;
  Folder? get selectedFolder => foldersController.selectedFolder;
  SidebarSection get activeSection => snippetsController.activeSection;

  Future<void> initialize() async {
    await foldersController.loadFolders();
    await snippetsController.initialize();
  }

  Future<void> selectFolder(Folder? folder) async {
    foldersController.selectFolder(folder);
    await snippetsController.loadSnippets(
      section: SidebarSection.all,
      folderId: folder?.id,
    );
  }

  Future<void> selectSection(SidebarSection section) async {
    foldersController.selectFolder(null);
    await snippetsController.loadSnippets(section: section, folderId: null);
  }

  Future<void> deleteFolder(String id) async {
    final wasSelected = foldersController.selectedFolder?.id == id;
    final snippetsInFolder = await snippetRepository.getSnippetsByFolderId(id);
    for (final snippet in snippetsInFolder) {
      await snippetRepository.saveSnippet(
        snippet.copyWith(isDeleted: true, updatedAt: DateTime.now()),
      );
    }

    await foldersController.deleteFolder(id);

    if (wasSelected) {
      await snippetsController.loadSnippets(
        section: SidebarSection.all,
        folderId: null,
      );
    }
  }

  Future<Folder> createFolder(String initialName, {String? parentId}) =>
      foldersController.createFolder(initialName, parentId: parentId);

  Future<void> renameFolder(String id, String newName) =>
      foldersController.renameFolder(id, newName);

  void selectSnippet(Snippet? snippet) =>
      snippetsController.selectSnippet(snippet);

  Future<void> toggleFavorite(String id) =>
      snippetsController.toggleFavorite(id);

  Future<void> deleteSnippet(String id) => snippetsController.deleteSnippet(id);

  Future<void> restoreSnippet(String id) =>
      snippetsController.restoreSnippet(id);

  Future<Snippet> createDefaultSnippet(
    String defaultName, {
    required String defaultFragmentBaseName,
  }) => snippetsController.createDefaultSnippet(
    defaultName,
    defaultFragmentBaseName: defaultFragmentBaseName,
    folderId: selectedFolder?.id,
  );

  Future<void> createSnippet(Snippet snippet) =>
      snippetsController.createSnippet(snippet, selectedFolder?.id);

  Future<void> updateSnippetName(String id, String newName) =>
      snippetsController.updateSnippetName(id, newName);

  Future<void> updateSnippetDescription(String id, String newDescription) =>
      snippetsController.updateSnippetDescription(id, newDescription);

  Future<void> addFragment(String snippetId, String baseName) =>
      fragmentsController.addFragment(snippetId, baseName);

  Future<void> setActiveFragment(String snippetId, String fragmentId) =>
      fragmentsController.setActiveFragment(snippetId, fragmentId);

  Future<void> updateFragment(
    String snippetId,
    String fragmentId,
    String newName,
  ) => fragmentsController.updateFragment(snippetId, fragmentId, newName);

  Future<void> updateFragmentContent(
    String snippetId,
    String fragmentId,
    String newContent,
  ) => fragmentsController.updateFragmentContent(
    snippetId,
    fragmentId,
    newContent,
  );

  Future<void> updateFragmentName(
    String snippetId,
    String fragmentId,
    String newName,
  ) => fragmentsController.updateFragmentName(snippetId, fragmentId, newName);

  Future<void> updateFragmentLanguage(
    String snippetId,
    String fragmentId,
    String newLanguage,
  ) => fragmentsController.updateFragmentLanguage(
    snippetId,
    fragmentId,
    newLanguage,
  );
}
