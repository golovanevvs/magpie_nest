class Folder {
  final String id;
  final String name;
  final String? parentId;
  final int sortOrder;

  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    this.sortOrder = 0,
  });

  bool get isRoot => parentId == null;

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
