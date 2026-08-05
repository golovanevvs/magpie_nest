import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';

abstract class ISnippetRepository {
  Future<List<Snippet>> getAllSnippets();
  Future<Snippet?> getSnippetById(String id);
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId);
  Future<List<Snippet>> getFavoriteSnippets();
  Future<List<Snippet>> getDeletedSnippets();
  Future<void> saveSnippet(Snippet snippet);
  Future<void> deleteSnippet(String id);
  Future<void> restoreSnippet(String id);
  Future<void> permanentlyDeleteSnippet(String id);
}
