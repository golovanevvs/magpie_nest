import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';

class InMemoryFolderRepository implements IFolderRepository {
  final List<Folder> _folders = [
    const Folder(id: 'folder-work', name: 'Work', sortOrder: 0),
    const Folder(id: 'folder-personal', name: 'Personal', sortOrder: 1),
    const Folder(
      id: 'folder-react',
      name: 'React Components',
      parentId: 'folder-work',
      sortOrder: 0,
    ),
    const Folder(
      id: 'folder-api',
      name: 'API Calls',
      parentId: 'folder-work',
      sortOrder: 1,
    ),
    const Folder(
      id: 'folder-scripts',
      name: 'Scripts',
      parentId: 'folder-personal',
      sortOrder: 0,
    ),
  ];

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
