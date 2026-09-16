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

/// Координатор: композиционный корень приложения.
///
/// Владеет тремя доменными контроллерами и связывает их воедино:
///  * [foldersController]   — папки;
///  * [snippetsController]  — сниппеты;
///  * [fragmentsController] — фрагменты.
///
/// Доменные контроллеры не знают друг о друге. Междоменные (cross-cutting)
/// операции — смена раздела/папки, удаление папки с зачисткой сниппетов,
/// загрузка при старте — выполняются здесь. Также координатор пробрасывает
/// уведомления дочерних контроллеров наверх, чтобы существующие виджеты,
/// слушающие единый источник ([ChangeNotifier]), продолжали перерисовываться.
///
/// Снаружи для совместимости с UI координатор отдаёт привычные геттеры и
/// методы и переадресует их в нужный доменный контроллер.
class AppController extends ChangeNotifier {
  final IFolderRepository folderRepository;
  final ISnippetRepository snippetRepository;

  final FoldersController foldersController;
  final SnippetsController snippetsController;
  late final FragmentsController fragmentsController;

  AppController({
    required this.folderRepository,
    required this.snippetRepository,
  })  : foldersController = FoldersController(folderRepository: folderRepository),
        snippetsController = SnippetsController(snippetRepository: snippetRepository) {
    fragmentsController = FragmentsController(
      snippetRepository: snippetRepository,
      snippetsController: snippetsController,
    );

    // Пробрасываем уведомления дочерних контроллеров наверх,
    // чтобы единый слушатель (например, в MainScreen) видел все изменения.
    foldersController.addListener(notifyListeners);
    snippetsController.addListener(notifyListeners);
  }

  // ---------- Чтение (делегирование в доменные контроллеры) ----------

  List<Snippet> get snippets => snippetsController.snippets;
  Snippet? get selectedSnippet => snippetsController.selectedSnippet;
  List<Folder> get folders => foldersController.folders;
  Folder? get selectedFolder => foldersController.selectedFolder;
  SidebarSection get activeSection => snippetsController.activeSection;

  // ---------- Композиция / междоменные операции ----------

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

  /// Удаляет папку и помечает её сниппеты как удалённые в репозитории.
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

  // ---------- Делегирование: папки ----------

  Future<Folder> createFolder(String initialName, {String? parentId}) =>
      foldersController.createFolder(initialName, parentId: parentId);

  Future<void> renameFolder(String id, String newName) =>
      foldersController.renameFolder(id, newName);

  // ---------- Делегирование: сниппеты ----------

  void selectSnippet(Snippet? snippet) => snippetsController.selectSnippet(snippet);

  Future<void> toggleFavorite(String id) => snippetsController.toggleFavorite(id);

  Future<void> deleteSnippet(String id) => snippetsController.deleteSnippet(id);

  Future<void> restoreSnippet(String id) => snippetsController.restoreSnippet(id);

  Future<Snippet> createDefaultSnippet(
    String defaultName, {
    required String defaultFragmentBaseName,
  }) =>
      snippetsController.createDefaultSnippet(
        defaultName,
        defaultFragmentBaseName: defaultFragmentBaseName,
        folderId: selectedFolder?.id,
      );

  Future<void> createSnippet(Snippet snippet) => snippetsController.createSnippet(
        snippet,
        selectedFolder?.id,
      );

  Future<void> updateSnippetName(String id, String newName) =>
      snippetsController.updateSnippetName(id, newName);

  Future<void> updateSnippetDescription(String id, String newDescription) =>
      snippetsController.updateSnippetDescription(id, newDescription);

  // ---------- Делегирование: фрагменты ----------

  Future<void> addFragment(String snippetId, String baseName) =>
      fragmentsController.addFragment(snippetId, baseName);

  Future<void> setActiveFragment(String snippetId, String fragmentId) =>
      fragmentsController.setActiveFragment(snippetId, fragmentId);

  Future<void> updateFragment(
    String snippetId,
    String fragmentId,
    String newName,
  ) =>
      fragmentsController.updateFragment(snippetId, fragmentId, newName);

  Future<void> updateFragmentContent(
    String snippetId,
    String fragmentId,
    String newContent,
  ) =>
      fragmentsController.updateFragmentContent(snippetId, fragmentId, newContent);

  Future<void> updateFragmentName(
    String snippetId,
    String fragmentId,
    String newName,
  ) =>
      fragmentsController.updateFragmentName(snippetId, fragmentId, newName);

  Future<void> updateFragmentLanguage(
    String snippetId,
    String fragmentId,
    String newLanguage,
  ) =>
      fragmentsController.updateFragmentLanguage(snippetId, fragmentId, newLanguage);
}
