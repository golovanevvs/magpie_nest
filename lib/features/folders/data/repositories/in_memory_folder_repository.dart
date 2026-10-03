import 'package:magpie_nest/core/database/sample_data.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';

class InMemoryFolderRepository implements IFolderRepository {
  final List<Folder> _folders = sampleFolders();

  @override
  Future<List<Folder>> getAllFolders() async {
    return List.unmodifiable(_folders.where((f) => !f.isDeleted));
  }

  @override
  Future<Folder?> getFolderById(String id) async {
    try {
      return _folders.firstWhere((folder) => folder.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    final index = _folders.indexWhere((f) => f.id == folder.id);
    if (index >= 0) {
      _folders[index] = folder;
    } else {
      _folders.add(folder);
    }
  }

  @override
  Future<List<String>> getDescendantIds(String id) async {
    final descendants = <String>[];
    final stack = [id];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      for (final folder in _folders) {
        if (folder.parentId == current) {
          descendants.add(folder.id);
          stack.add(folder.id);
        }
      }
    }
    return descendants;
  }

  @override
  Future<void> deleteFolder(String id) async {
    final now = DateTime.now();
    final subtreeIds = {id, ...await getDescendantIds(id)};

    for (var i = 0; i < _folders.length; i++) {
      if (subtreeIds.contains(_folders[i].id)) {
        _folders[i] = _folders[i].copyWith(
          isDeleted: true,
          deletedAt: now,
          updatedAt: now,
        );
      }
    }
  }
}
