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
    _folders = await folderRepository.getAllFolders();
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

  /// Loads only favorite snippets into the list.
  Future<void> loadFavoriteSnippets() async {
    _selectedFolder = null;
    _selectedSnippet = null;
    _snippets = await snippetRepository.getFavoriteSnippets();
    notifyListeners();
  }

  /// Loads only deleted snippets (from Trash) into the list.
  Future<void> loadDeletedSnippets() async {
    _selectedFolder = null;
    _selectedSnippet = null;
    _snippets = await snippetRepository.getDeletedSnippets();
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
      _snippets = await snippetRepository.getSnippetsByFolderId(folderId);
    }
  }
}
