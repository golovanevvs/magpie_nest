import 'package:flutter/material.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';

enum SidebarSection { all, inbox, favorites, trash }

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

  List<Folder> get folders => _folders;

  List<Snippet> get snippets {
    if (_selectedTag == null || _selectedTag!.isEmpty) return _snippets;
    return _snippets.where((s) => s.tags.contains(_selectedTag)).toList();
  }

  Set<String> get tags {
    final result = <String>{};
    for (final snippet in _snippets) {
      result.addAll(snippet.tags);
    }
    return result;
  }

  Folder? get selectedFolder => _selectedFolder;

  Snippet? get selectedSnippet => _selectedSnippet;

  SidebarSection get activeSection => _activeSection;

  String? get selectedTag => _selectedTag;

  Future<void> initialize() async {
    _folders = (await folderRepository.getAllFolders()).toList();
    _selectedFolder = null;
    _activeSection = SidebarSection.all;
    await _loadSnippetsBySection();
    notifyListeners();
  }

  Future<void> selectFolder(Folder? folder) async {
    _selectedFolder = folder;
    _selectedSnippet = null;
    _selectedTag = null;
    _activeSection = SidebarSection.all;
    await _loadSnippetsBySection();
    notifyListeners();
  }

  Future<void> selectSection(SidebarSection section) async {
    _activeSection = section;
    _selectedFolder = null;
    _selectedSnippet = null;
    _selectedTag = null;
    await _loadSnippetsBySection();
    notifyListeners();
  }

  void selectTag(String? tag) {
    _selectedTag = tag;
    _selectedSnippet = null;
    notifyListeners();
  }

  void selectSnippet(Snippet snippet) {
    _selectedSnippet = snippet;
    notifyListeners();
  }

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

  Future<void> updateSnippetDescription(
    String id,
    String newDescription,
  ) async {
    final trimmedDescription = newDescription.trim();
    final snippet = await snippetRepository.getSnippetById(id);
    if (snippet == null) return;

    final updated = snippet.copyWith(
      description: trimmedDescription.isEmpty ? null : trimmedDescription,
      clearDescription: trimmedDescription.isEmpty,
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
