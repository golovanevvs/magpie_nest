import 'package:magpie_nest/features/folders/domain/models/folder.dart';

/// Contract for folder storage implementations.
///
/// This interface defines the operations that any folder repository
/// (in-memory, SQLite, remote API, etc.) must support.
///
/// See also:
///  * [InMemoryFolderRepository], the default implementation for development.
abstract class IFolderRepository {
  /// Returns all folders.
  Future<List<Folder>> getAllFolders();

  /// Returns the folder with the given [id], or `null` if not found.
  Future<Folder?> getFolderById(String id);

  /// Saves the given [folder].
  ///
  /// Creates a new folder if no folder with the same id exists,
  /// otherwise updates the existing one.
  Future<void> saveFolder(Folder folder);

  /// Deletes the folder with the given [id].
  ///
  /// All nested folders are deleted recursively.
  /// Snippets belonging to these folders are moved to Inbox (`folderId = null`).
  Future<void> deleteFolder(String id);
}
