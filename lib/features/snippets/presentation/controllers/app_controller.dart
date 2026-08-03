import 'package:flutter/material.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';

/// Available sidebar sections that filter the snippet list.
enum SidebarSection { all, inbox, favorites, trash }

/// Controller for managing the main screen state.
///
/// Holds the selected folder and snippet, and provides methods
/// for loading data from repositories.
///
/// This controller acts as a bridge between the domain layer
/// (repositories) and the presentation layer (UI widgets).
class AppController extends ChangeNotifier {
  final IFolderRepository folderRepository;
  final ISnippetRepository snippetRepository;

  List<Folder> _folders = [];
  List<Snippet> _snippets = [];

  Folder? _selectedFolder;
  Snippet? _selectedSnippet;
  String? _selectedTag;
  SidebarSection _activeSection = SidebarSection.all;

  AppController({
    required this.folderRepository,
    required this.snippetRepository,
  });

  /// Returns all loaded folders.
  List<Folder> get folders => _folders;

  /// Returns snippets filtered by the current selection and selected tag.
  List<Snippet> get snippets {
    if (_selectedTag == null || _selectedTag!.isEmpty) return _snippets;
    return _snippets.where((s) => s.tags.contains(_selectedTag)).toList();
  }

  /// Returns all unique tags from the currently loaded snippets.
  Set<String> get tags {
    final result = <String>{};
    for (final snippet in _snippets) {
      result.addAll(snippet.tags);
    }
    return result;
  }

  /// Returns the currently selected folder, or `null` if a virtual folder is active.
  Folder? get selectedFolder => _selectedFolder;

  /// Returns the currently selected snippet for viewing.
  Snippet? get selectedSnippet => _selectedSnippet;

  /// Returns the currently active sidebar section.
  SidebarSection get activeSection => _activeSection;

  /// Returns the currently selected tag, or `null` if no tag is selected.
  String? get selectedTag => _selectedTag;

  /// Initializes the controller by loading all folders and selecting "All Snippets" by default.
  ///
  /// This method should be called once when the main screen is first displayed.
  Future<void> initialize() async {
    _folders = (await folderRepository.getAllFolders()).toList();
    _selectedFolder = null;
    _activeSection = SidebarSection.all;
    await _loadSnippetsBySection();
    notifyListeners();
  }

  /// Selects a folder and loads the corresponding snippets.
  ///
  /// Resets the active section, selected tag and the selected snippet.
  Future<void> selectFolder(Folder? folder) async {
    _selectedFolder = folder;
    _selectedSnippet = null;
    _selectedTag = null;
    _activeSection = SidebarSection.all;
    await _loadSnippetsBySection();
    notifyListeners();
  }

  /// Selects a sidebar section and loads the corresponding snippets.
  ///
  /// Resets the selected folder, tag and snippet.
  Future<void> selectSection(SidebarSection section) async {
    _activeSection = section;
    _selectedFolder = null;
    _selectedSnippet = null;
    _selectedTag = null;
    await _loadSnippetsBySection();
    notifyListeners();
  }

  /// Selects a tag and filters the snippet list.
  ///
  /// Keeps the current active section/folder, but clears the selected snippet.
  void selectTag(String? tag) {
    _selectedTag = tag;
    _selectedSnippet = null;
    notifyListeners();
  }

  /// Selects a specific snippet for viewing in the right panel.
  void selectSnippet(Snippet snippet) {
    _selectedSnippet = snippet;
    notifyListeners();
  }

  /// Toggles the favorite status of the snippet with the given [id].
  ///
  /// Updates the snippet in the repository and refreshes the local state.
  Future<void> toggleFavorite(String id) async {
    final snippet = await snippetRepository.getSnippetById(id);
    if (snippet == null) return;

    final updated = snippet.copyWith(
      isFavorite: !snippet.isFavorite,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);

    if (_activeSection == SidebarSection.favorites && !updated.isFavorite) {
      _snippets.removeWhere((s) => s.id == id);
    } else {
      final snippetIndex = _snippets.indexWhere((s) => s.id == id);
      if (snippetIndex >= 0) {
        _snippets[snippetIndex] = updated;
      }
    }

    if (_selectedSnippet?.id == id) {
      _selectedSnippet = updated;
    }

    notifyListeners();
  }

  /// Soft-deletes the snippet with the given [id] (moves it to the Trash).
  ///
  /// Updates the snippet in the repository and refreshes the local state.
  /// The snippet can later be restored using [restoreSnippet].
  Future<void> deleteSnippet(String id) async {
    await snippetRepository.deleteSnippet(id);

    if (_activeSection == SidebarSection.trash) {
      final restored = await snippetRepository.getSnippetById(id);
      if (restored != null) {
        final index = _snippets.indexWhere((s) => s.id == id);
        if (index >= 0) {
          _snippets[index] = restored;
        } else {
          _snippets.add(restored);
        }
      }
    } else {
      _snippets.removeWhere((s) => s.id == id);
    }

    if (_selectedSnippet?.id == id) {
      _selectedSnippet = null;
    }

    notifyListeners();
  }

  /// Restores the snippet with the given [id] from the Trash.
  ///
  /// The snippet is always moved to the Inbox.
  Future<void> restoreSnippet(String id) async {
    var restored = await snippetRepository.getSnippetById(id);
    if (restored == null) return;

    restored = restored.copyWith(
      isDeleted: false,
      clearFolderId: true,
      updatedAt: DateTime.now(),
    );
    await snippetRepository.saveSnippet(restored);

    if (_activeSection == SidebarSection.trash) {
      _snippets.removeWhere((s) => s.id == id);
    } else {
      final index = _snippets.indexWhere((s) => s.id == id);
      if (index >= 0) {
        _snippets[index] = restored;
      } else {
        _snippets.add(restored);
      }
    }

    if (_selectedSnippet?.id == id) {
      _selectedSnippet = null;
    }

    notifyListeners();
  }

  /// Loads snippets based on the active section and selected folder.
  Future<void> _loadSnippetsBySection() async {
    switch (_activeSection) {
      case SidebarSection.all:
        final all = await snippetRepository.getAllSnippets();
        if (_selectedFolder == null) {
          _snippets = all.where((s) => !s.isDeleted).toList();
        } else {
          _snippets = all
              .where((s) => !s.isDeleted && s.folderId == _selectedFolder!.id)
              .toList();
        }
        break;
      case SidebarSection.inbox:
        final all = await snippetRepository.getAllSnippets();
        _snippets = all.where((s) => !s.isDeleted && s.isInbox).toList();
        break;
      case SidebarSection.favorites:
        _snippets = (await snippetRepository.getFavoriteSnippets()).toList();
        break;
      case SidebarSection.trash:
        _snippets = (await snippetRepository.getDeletedSnippets()).toList();
        break;
    }
    notifyListeners();
  }

  /// Creates a new snippet with a generated unique name and adds it to the repository.
  ///
  /// The snippet is added to the current folder (or Inbox if no folder is selected).
  /// Returns the created snippet so the UI can select it immediately.
  Future<Snippet> createDefaultSnippet(String defaultName) async {
    String newName = '$defaultName 1';
    int counter = 1;

    while (_snippets.any(
      (s) => s.name.toLowerCase() == newName.toLowerCase(),
    )) {
      counter++;
      newName = '$defaultName $counter';
    }

    final snippet = Snippet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      fragments: const [
        Fragment(id: '1', name: 'fragment', language: 'plaintext', content: ''),
      ],
      folderId: _selectedFolder?.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(snippet);

    final shouldShow = switch (_activeSection) {
      SidebarSection.all => snippet.folderId == _selectedFolder?.id,
      SidebarSection.inbox => snippet.isInbox,
      SidebarSection.favorites => snippet.isFavorite,
      SidebarSection.trash => snippet.isDeleted,
    };

    if (shouldShow) {
      _snippets.insert(0, snippet);
    }

    _selectedSnippet = snippet;
    notifyListeners();
    return snippet;
  }

  /// Creates a new snippet and adds it to the repository.
  ///
  /// The snippet is added to the current folder (or Inbox if no folder is selected).
  Future<void> createSnippet(Snippet snippet) async {
    final newSnippet = snippet.copyWith(folderId: _selectedFolder?.id);

    await snippetRepository.saveSnippet(newSnippet);

    final shouldShow = switch (_activeSection) {
      SidebarSection.all => newSnippet.folderId == _selectedFolder?.id,
      SidebarSection.inbox => newSnippet.isInbox,
      SidebarSection.favorites => newSnippet.isFavorite,
      SidebarSection.trash => newSnippet.isDeleted,
    };

    if (shouldShow) {
      _snippets.insert(0, newSnippet);
    }

    notifyListeners();
  }

  /// Updates the name of the snippet with the given [id].
  ///
  /// Empty names are ignored. The snippet is saved to the repository
  /// and the local state is refreshed.
  Future<void> updateSnippetName(String id, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    final snippet = await snippetRepository.getSnippetById(id);
    if (snippet == null) return;

    final updated = snippet.copyWith(
      name: trimmedName,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);

    final index = _snippets.indexWhere((s) => s.id == id);
    if (index >= 0) {
      _snippets[index] = updated;
    }

    if (_selectedSnippet?.id == id) {
      _selectedSnippet = updated;
    }

    notifyListeners();
  }

  /// Creates a new folder and returns it.
  ///
  /// Generates a unique name based on [initialName] (e.g., "New Folder 1").
  /// If [parentId] is provided, the folder is created as a subfolder.
  Future<Folder> createFolder(String initialName, {String? parentId}) async {
    String newName = '$initialName 1';
    int counter = 1;

    while (_folders.any((f) => f.name.toLowerCase() == newName.toLowerCase())) {
      counter++;
      newName = '$initialName $counter';
    }

    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      parentId: parentId,
      sortOrder: _folders.length,
    );

    await folderRepository.saveFolder(folder);
    _folders.add(folder);

    _selectedFolder = folder;

    notifyListeners();
    return folder;
  }

  /// Renames the folder with the given [id].
  Future<void> renameFolder(String id, String newName) async {
    final folder = await folderRepository.getFolderById(id);
    if (folder == null) return;

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == folder.name) return;

    final updated = folder.copyWith(name: trimmedName);
    await folderRepository.saveFolder(updated);

    final index = _folders.indexWhere((f) => f.id == id);
    if (index >= 0) {
      _folders[index] = updated;
    }

    notifyListeners();
  }

  /// Deletes the folder and moves its snippets to the Trash.
  ///
  /// Snippets keep their folderId reference so restoration logic can decide
  /// whether to return them to the original folder or to the Inbox.
  Future<void> deleteFolder(String id) async {
    final snippetsInFolder = await snippetRepository.getSnippetsByFolderId(id);
    for (final snippet in snippetsInFolder) {
      await snippetRepository.saveSnippet(
        snippet.copyWith(isDeleted: true, updatedAt: DateTime.now()),
      );
    }

    await folderRepository.deleteFolder(id);
    _folders.removeWhere((f) => f.id == id);

    if (_selectedFolder?.id == id) {
      _selectedFolder = null;
      await _loadSnippetsBySection();
    }

    notifyListeners();
  }
}
