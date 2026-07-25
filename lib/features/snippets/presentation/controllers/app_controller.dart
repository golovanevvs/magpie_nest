import 'package:flutter/material.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';

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

  AppController({
    required this.folderRepository,
    required this.snippetRepository,
  });

  /// Returns all loaded folders.
  List<Folder> get folders => _folders;

  /// Returns snippets filtered by the current selection.
  List<Snippet> get snippets => _snippets;

  /// Returns the currently selected folder, or `null` if "All Snippets" is active.
  Folder? get selectedFolder => _selectedFolder;

  /// Returns the currently selected snippet for viewing.
  Snippet? get selectedSnippet => _selectedSnippet;

  /// Initializes the controller by loading all folders and selecting "All Snippets" by default.
  ///
  /// This method should be called once when the main screen is first displayed.
  Future<void> initialize() async {
    _folders = (await folderRepository.getAllFolders()).toList();
    _snippets = (await snippetRepository.getAllSnippets()).toList();
    _selectedFolder = null;
    await _loadSnippetsForFolder(null);
    notifyListeners();
  }

  /// Selects a folder and loads the corresponding snippets.
  ///
  /// Pass `null` to show all snippets (virtual "All Snippets" folder).
  /// Resets the selected snippet when the folder changes.
  Future<void> selectFolder(Folder? folder) async {
    _selectedFolder = folder;
    _selectedSnippet = null;
    await _loadSnippetsForFolder(folder?.id);
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

    final snippetIndex = _snippets.indexWhere((s) => s.id == id);
    if (snippetIndex >= 0) {
      _snippets[snippetIndex] = updated;
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

    _snippets.removeWhere((s) => s.id == id);

    if (_selectedSnippet?.id == id) {
      _selectedSnippet = null;
    }

    notifyListeners();
  }

  /// Restores the snippet with the given [id] from the Trash.
  ///
  /// Updates the snippet in the repository and refreshes the local state.
  Future<void> restoreSnippet(String id) async {
    await snippetRepository.restoreSnippet(id);

    _snippets.removeWhere((s) => s.id == id);

    if (_selectedSnippet?.id == id) {
      _selectedSnippet = null;
    }

    notifyListeners();
  }

  /// Loads only favorite snippets into the list.
  Future<void> loadFavoriteSnippets() async {
    _selectedFolder = null;
    _selectedSnippet = null;
    _snippets = (await snippetRepository.getFavoriteSnippets()).toList();
    notifyListeners();
  }

  /// Loads only deleted snippets (from Trash) into the list.
  Future<void> loadDeletedSnippets() async {
    _selectedFolder = null;
    _selectedSnippet = null;
    _snippets = (await snippetRepository.getDeletedSnippets()).toList();
    notifyListeners();
  }

  /// Loads snippets based on the folder ID.
  ///
  /// If [folderId] is `null`, loads all non-deleted snippets (virtual "All Snippets").
  /// Otherwise, loads snippets belonging to the specified folder.
  Future<void> _loadSnippetsForFolder(String? folderId) async {
    if (folderId == null) {
      final all = await snippetRepository.getAllSnippets();
      _snippets = all.where((s) => !s.isDeleted).toList();
    } else {
      _snippets = (await snippetRepository.getSnippetsByFolderId(folderId))
          .toList();
    }
    notifyListeners();
  }

  /// Creates a new snippet and adds it to the repository.
  ///
  /// The snippet is added to the current folder (or Inbox if no folder is selected).
  Future<void> createSnippet(Snippet snippet) async {
    final newSnippet = snippet.copyWith(folderId: _selectedFolder?.id);

    await snippetRepository.saveSnippet(newSnippet);
    _snippets.insert(0, newSnippet);

    notifyListeners();
  }

  /// Creates a new folder and returns it.
  ///
  /// Generates a unique name based on [initialName] (e.g., "Untitled Folder 1").
  Future<Folder> createFolder(String initialName) async {
    String newName = initialName;
    int counter = 1;

    while (_folders.any((f) => f.name.toLowerCase() == newName.toLowerCase())) {
      newName = '$initialName $counter';
      counter++;
    }

    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
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

  /// Deletes the folder and moves its snippets to Inbox.
  Future<void> deleteFolder(String id) async {
    final snippetsInFolder = await snippetRepository.getSnippetsByFolderId(id);
    for (final snippet in snippetsInFolder) {
      await snippetRepository.saveSnippet(snippet.copyWith(folderId: null));
    }

    await folderRepository.deleteFolder(id);
    _folders.removeWhere((f) => f.id == id);

    if (_selectedFolder?.id == id) {
      _selectedFolder = null;
      await _loadSnippetsForFolder(null);
    }

    notifyListeners();
  }
}
