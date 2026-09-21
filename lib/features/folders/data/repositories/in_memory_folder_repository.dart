import 'package:magpie_nest/core/database/sample_data.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';

class InMemoryFolderRepository implements IFolderRepository {
  final List<Folder> _folders = sampleFolders();

  @override
  Future<List<Folder>> getAllFolders() async {
    return List.unmodifiable(_folders);
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
  Future<void> deleteFolder(String id) async {
    _folders.removeWhere((folder) => folder.id == id || folder.parentId == id);
  }
}
