import 'package:magpie_nest/core/database/sample_data.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';

class InMemorySnippetRepository implements ISnippetRepository {
  final List<Snippet> _snippets = sampleSnippets();

  @override
  Future<List<Snippet>> getAllSnippets() async {
    return List.unmodifiable(_snippets);
  }

  @override
  Future<Snippet?> getSnippetById(String id) async {
    try {
      return _snippets.firstWhere((snippet) => snippet.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId) async {
    return _snippets.where((snippet) => snippet.folderId == folderId).toList();
  }

  @override
  Future<List<Snippet>> getFavoriteSnippets() async {
    return _snippets.where((snippet) => snippet.isFavorite).toList();
  }

  @override
  Future<List<Snippet>> getDeletedSnippets() async {
    return _snippets.where((snippet) => snippet.isDeleted).toList();
  }

  @override
  Future<void> saveSnippet(Snippet snippet) async {
    final index = _snippets.indexWhere((s) => s.id == snippet.id);
    if (index >= 0) {
      _snippets[index] = snippet;
    } else {
      _snippets.add(snippet);
    }
  }

  @override
  Future<void> deleteSnippet(String id) async {
    final index = _snippets.indexWhere((snippet) => snippet.id == id);
    if (index >= 0) {
      _snippets[index] = _snippets[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> restoreSnippet(String id) async {
    final index = _snippets.indexWhere((snippet) => snippet.id == id);
    if (index >= 0) {
      _snippets[index] = _snippets[index].copyWith(
        isDeleted: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> permanentlyDeleteSnippet(String id) async {
    _snippets.removeWhere((snippet) => snippet.id == id);
  }

  @override
  Future<void> permanentlyDeleteDeletedSnippets() async {
    _snippets.removeWhere((snippet) => snippet.isDeleted);
  }
}
