import 'package:flutter/foundation.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/sidebar_section.dart';

class SnippetsController extends ChangeNotifier {
  final ISnippetRepository snippetRepository;

  List<Snippet> _snippets = [];
  Snippet? _selectedSnippet;
  SidebarSection _activeSection = SidebarSection.all;

  SnippetsController({required this.snippetRepository});

  List<Snippet> get snippets => _snippets;
  Snippet? get selectedSnippet => _selectedSnippet;
  SidebarSection get activeSection => _activeSection;

  Future<void> initialize() async {
    _activeSection = SidebarSection.all;
    _selectedSnippet = null;
    await _loadSnippets(section: SidebarSection.all, folderId: null);
    notifyListeners();
  }

  Future<void> loadSnippets({
    required SidebarSection section,
    String? folderId,
  }) async {
    _activeSection = section;
    _selectedSnippet = null;
    await _loadSnippets(section: section, folderId: folderId);
    notifyListeners();
  }

  void selectSnippet(Snippet? snippet) {
    _selectedSnippet = snippet;
    notifyListeners();
  }

  void applySnippetUpdate(Snippet updated) {
    final index = _snippets.indexWhere((s) => s.id == updated.id);
    if (index >= 0) {
      _snippets[index] = updated;
    }

    if (_selectedSnippet?.id == updated.id) {
      _selectedSnippet = updated;
    }

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

  Future<void> permanentlyDeleteSnippet(String id) async {
    await snippetRepository.permanentlyDeleteSnippet(id);
    _snippets.removeWhere((s) => s.id == id);
    if (_selectedSnippet?.id == id) {
      _selectedSnippet = null;
    }
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    await snippetRepository.permanentlyDeleteDeletedSnippets();
    _snippets.removeWhere((s) => s.isDeleted);
    if (_selectedSnippet?.isDeleted == true) {
      _selectedSnippet = null;
    }
    notifyListeners();
  }

  Future<Snippet> createDefaultSnippet(
    String defaultName, {
    required String defaultFragmentBaseName,
    String? folderId,
  }) async {
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
      fragments: [
        Fragment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '$defaultFragmentBaseName 1',
          language: 'plaintext',
          content: '',
        ),
      ],
      folderId: folderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(snippet);

    final shouldShow = switch (_activeSection) {
      SidebarSection.all => snippet.folderId == folderId,
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

  Future<void> createSnippet(Snippet snippet, String? folderId) async {
    final newSnippet = snippet.copyWith(folderId: folderId);

    await snippetRepository.saveSnippet(newSnippet);

    final shouldShow = switch (_activeSection) {
      SidebarSection.all => newSnippet.folderId == folderId,
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

  Future<void> _loadSnippets({
    required SidebarSection section,
    String? folderId,
  }) async {
    switch (section) {
      case SidebarSection.all:
        final all = await snippetRepository.getAllSnippets();
        if (folderId == null) {
          _snippets = all.where((s) => !s.isDeleted).toList();
        } else {
          _snippets = all
              .where((s) => !s.isDeleted && s.folderId == folderId)
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
  }
}
