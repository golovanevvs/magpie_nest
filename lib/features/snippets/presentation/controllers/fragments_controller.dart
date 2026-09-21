import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/snippets_controller.dart';

class FragmentsController {
  final ISnippetRepository snippetRepository;
  final SnippetsController snippetsController;

  FragmentsController({
    required this.snippetRepository,
    required this.snippetsController,
  });

  Future<void> addFragment(String snippetId, String baseName) async {
    final snippet = await snippetRepository.getSnippetById(snippetId);
    if (snippet == null) return;

    final newNumber = snippet.fragments.length + 1;
    final newFragment = Fragment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '$baseName $newNumber',
      language: 'plaintext',
      content: '',
    );

    final updated = snippet.copyWith(
      fragments: [...snippet.fragments, newFragment],
      activeFragmentId: newFragment.id,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);
    snippetsController.applySnippetUpdate(updated);
  }

  Future<void> setActiveFragment(String snippetId, String fragmentId) async {
    final snippet = await snippetRepository.getSnippetById(snippetId);
    if (snippet == null) return;

    if (!snippet.fragments.any((f) => f.id == fragmentId)) return;

    final updated = snippet.copyWith(
      activeFragmentId: fragmentId,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);
    snippetsController.applySnippetUpdate(updated);
  }

  Future<void> updateFragment(
    String snippetId,
    String fragmentId,
    String newName,
  ) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    final snippet = await snippetRepository.getSnippetById(snippetId);
    if (snippet == null) return;

    final fragmentIndex = snippet.fragments.indexWhere(
      (f) => f.id == fragmentId,
    );
    if (fragmentIndex < 0) return;

    final updatedFragment = snippet.fragments[fragmentIndex].copyWith(
      name: trimmedName,
    );

    final updatedFragments = [...snippet.fragments];
    updatedFragments[fragmentIndex] = updatedFragment;

    final updated = snippet.copyWith(
      fragments: updatedFragments,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);
    snippetsController.applySnippetUpdate(updated);
  }

  Future<void> updateFragmentContent(
    String snippetId,
    String fragmentId,
    String newContent,
  ) async {
    final snippet = await snippetRepository.getSnippetById(snippetId);
    if (snippet == null) return;

    final fragmentIndex = snippet.fragments.indexWhere(
      (f) => f.id == fragmentId,
    );
    if (fragmentIndex < 0) return;

    final updatedFragment = snippet.fragments[fragmentIndex].copyWith(
      content: newContent,
    );

    final updatedFragments = [...snippet.fragments];
    updatedFragments[fragmentIndex] = updatedFragment;

    final updated = snippet.copyWith(
      fragments: updatedFragments,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);
    snippetsController.applySnippetUpdate(updated);
  }

  Future<void> updateFragmentName(
    String snippetId,
    String fragmentId,
    String newName,
  ) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    final snippet = await snippetRepository.getSnippetById(snippetId);
    if (snippet == null) return;

    final fragmentIndex = snippet.fragments.indexWhere(
      (f) => f.id == fragmentId,
    );
    if (fragmentIndex < 0) return;

    final updatedFragment = snippet.fragments[fragmentIndex].copyWith(
      name: trimmedName,
    );

    final updatedFragments = [...snippet.fragments];
    updatedFragments[fragmentIndex] = updatedFragment;

    final updated = snippet.copyWith(
      fragments: updatedFragments,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);
    snippetsController.applySnippetUpdate(updated);
  }

  Future<void> updateFragmentLanguage(
    String snippetId,
    String fragmentId,
    String newLanguage,
  ) async {
    final snippet = await snippetRepository.getSnippetById(snippetId);
    if (snippet == null) return;

    final fragmentIndex = snippet.fragments.indexWhere(
      (f) => f.id == fragmentId,
    );
    if (fragmentIndex < 0) return;

    final updatedFragment = snippet.fragments[fragmentIndex].copyWith(
      language: newLanguage,
    );

    final updatedFragments = [...snippet.fragments];
    updatedFragments[fragmentIndex] = updatedFragment;

    final updated = snippet.copyWith(
      fragments: updatedFragments,
      updatedAt: DateTime.now(),
    );

    await snippetRepository.saveSnippet(updated);
    snippetsController.applySnippetUpdate(updated);
  }
}
