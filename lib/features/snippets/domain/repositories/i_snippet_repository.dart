import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';

/// Contract for snippet storage implementations.
///
/// This interface defines the operations that any snippet repository
/// (in-memory, SQLite, remote API, etc.) must support.
///
/// See also:
///  * [InMemorySnippetRepository], the default implementation for development.
abstract class ISnippetRepository {
  /// Returns all snippets.
  Future<List<Snippet>> getAllSnippets();

  /// Returns the snippet with the given [id], or `null` if not found.
  Future<Snippet?> getSnippetById(String id);

  /// Returns snippets in the folder with the given [folderId].
  ///
  /// If [folderId] is `null`, returns snippets from the Inbox.
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId);

  /// Returns all favorite snippets.
  Future<List<Snippet>> getFavoriteSnippets();

  /// Returns all soft-deleted snippets (from the Trash).
  Future<List<Snippet>> getDeletedSnippets();

  /// Saves the given [snippet].
  ///
  /// Creates a new snippet if no snippet with the same id exists,
  /// otherwise updates the existing one.
  Future<void> saveSnippet(Snippet snippet);

  /// Soft-deletes the snippet with the given [id] (moves it to the Trash).
  Future<void> deleteSnippet(String id);

  /// Restores the snippet with the given [id] from the Trash.
  Future<void> restoreSnippet(String id);

  /// Permanently deletes the snippet with the given [id].
  ///
  /// This operation is irreversible.
  Future<void> permanentlyDeleteSnippet(String id);
}
