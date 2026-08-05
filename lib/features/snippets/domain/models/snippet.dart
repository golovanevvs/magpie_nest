import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';

class Snippet {
  final String id;
  final String name;
  final String? description;
  final List<Fragment> fragments;
  final String? activeFragmentId;
  final String? folderId;
  final List<String> tags;
  final bool isFavorite;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Snippet({
    required this.id,
    required this.name,
    this.description,
    required this.fragments,
    this.activeFragmentId,
    this.folderId,
    this.tags = const [],
    this.isFavorite = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         fragments.isNotEmpty,
         'A snippet must have at least one fragment.',
       );

  Fragment get activeFragment {
    if (fragments.isEmpty) {
      throw StateError('A snippet must have at least one fragment.');
    }
    return fragments.firstWhere(
      (fragment) => fragment.id == activeFragmentId,
      orElse: () => fragments.first,
    );
  }

  bool get isInbox => folderId == null;

  bool get isTrash => isDeleted;

  Snippet copyWith({
    String? id,
    String? name,
    String? description,
    bool clearDescription = false,
    List<Fragment>? fragments,
    String? activeFragmentId,
    bool clearActiveFragmentId = false,
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
      description: clearDescription ? null : (description ?? this.description),
      fragments: fragments ?? this.fragments,
      activeFragmentId: clearActiveFragmentId
          ? null
          : (activeFragmentId ?? this.activeFragmentId),
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
      'Snippet(id: $id, name: $name, folderId: $folderId, fragments: ${fragments.length})';
}
