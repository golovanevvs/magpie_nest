/// Model representing a folder for organizing snippets.
///
/// Folders support nesting through the [parentId] field.
/// A folder with `parentId == null` is considered a root-level folder.
///
/// The [sortOrder] field determines the display order of folders in the UI.
///
/// See also:
///  * [Snippet], which can reference a folder via its `folderId` field.
class Folder {
  /// Unique identifier of the folder.
  final String id;

  /// Display name of the folder.
  final String name;

  /// Identifier of the parent folder, or `null` if this is a root folder.
  final String? parentId;

  /// Order in which the folder should be displayed relative to its siblings.
  final int sortOrder;

  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    this.sortOrder = 0,
  });

  /// Whether this folder is a root-level folder (has no parent).
  bool get isRoot => parentId == null;

  /// Creates a copy of this folder with the given fields replaced.
  ///
  /// The [clearParentId] flag allows explicitly setting [parentId] to `null`
  /// (moving the folder to the root level). Passing `parentId: null` without
  /// this flag will keep the original value, since `null` means "no change".
  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    bool clearParentId = false,
    int? sortOrder,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Folder(id: $id, name: $name, parentId: $parentId)';
}
