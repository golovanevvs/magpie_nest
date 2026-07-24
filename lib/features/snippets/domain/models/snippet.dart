/// Model representing a code snippet.
///
/// The architecture follows the massCode design:
/// - [language] is a free-form string (not an enum), used for syntax highlighting.
/// - [folderId] references a folder. If `null`, the snippet is in the "Inbox".
/// - [isDeleted] indicates soft-deletion (the snippet is moved to the "Trash").
/// - [tags] is a list of strings used for cross-categorization.
///
/// Virtual folders (computed on the fly, not stored in the database):
/// - **All Snippets**: all snippets where `isDeleted == false`.
/// - **Inbox**: snippets where `folderId == null`.
/// - **Favorites**: snippets where `isFavorite == true`.
/// - **Trash**: snippets where `isDeleted == true`.
///
/// See also:
///  * [Folder], which snippets can reference via [folderId].
class Snippet {
  /// Unique identifier of the snippet.
  final String id;

  /// Display name of the snippet.
  final String name;

  /// Source code content of the snippet.
  final String content;

  /// Programming language of the snippet (e.g., "dart", "go", "typescript").
  ///
  /// Used primarily for syntax highlighting. Stored as a free-form string
  /// to allow any language, including custom or obscure ones.
  final String language;

  /// Identifier of the folder this snippet belongs to, or `null` for Inbox.
  final String? folderId;

  /// List of tags for cross-categorization.
  ///
  /// A snippet can belong to multiple tags simultaneously, unlike folders
  /// where a snippet can only be in one folder at a time.
  final List<String> tags;

  /// Whether this snippet is marked as a favorite.
  final bool isFavorite;

  /// Whether this snippet has been soft-deleted (moved to the Trash).
  final bool isDeleted;

  /// Timestamp when the snippet was created.
  final DateTime createdAt;

  /// Timestamp when the snippet was last updated.
  final DateTime updatedAt;

  const Snippet({
    required this.id,
    required this.name,
    required this.content,
    required this.language,
    this.folderId,
    this.tags = const [],
    this.isFavorite = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this snippet is in the Inbox (has no folder).
  bool get isInbox => folderId == null;

  /// Whether this snippet is in the Trash (soft-deleted).
  bool get isTrash => isDeleted;

  /// Creates a copy of this snippet with the given fields replaced.
  ///
  /// The [clearFolderId] flag allows explicitly setting [folderId] to `null`
  /// (moving the snippet to the Inbox). Similarly, [clearTags] allows
  /// resetting the tags list to empty. Passing `null` without these flags
  /// keeps the original values, since `null` means "no change".
  Snippet copyWith({
    String? id,
    String? name,
    String? content,
    String? language,
    String? folderId,
    bool clearFolderId = false,
    List<String>? tags,
    bool clearTags = false,
    bool? isFavorite,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Snippet(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      language: language ?? this.language,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      tags: clearTags ? const [] : (tags ?? this.tags),
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Snippet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Snippet(id: $id, name: $name, language: $language, folderId: $folderId)';
}
