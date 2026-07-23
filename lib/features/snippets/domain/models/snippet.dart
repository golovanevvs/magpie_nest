class Snippet {
  final String id;
  final String name;
  final String content;
  final String language;
  final String? folderId;
  final List<String> tags;
  final bool isFavorite;
  final bool isDeleted;
  final DateTime createdAt;
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

  bool get isInbox => folderId == null;

  bool get isTrash => isDeleted;

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
