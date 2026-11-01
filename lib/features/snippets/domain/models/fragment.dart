class Fragment {
  final String id;
  final String name;
  final String language;
  final String content;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final int revision;

  const Fragment({
    required this.id,
    required this.name,
    required this.language,
    required this.content,
    required this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.revision = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fragment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Fragment copyWith({
    String? id,
    String? name,
    String? language,
    String? content,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    int? revision,
  }) {
    return Fragment(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      revision: revision ?? this.revision,
    );
  }
}
