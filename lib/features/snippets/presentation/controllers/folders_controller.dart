import 'package:flutter/foundation.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/folders/domain/repositories/i_folder_repository.dart';

/// Контроллер домена «папки»: список папок, выбор активной папки
/// и CRUD-операции над папками.
class FoldersController extends ChangeNotifier {
  final IFolderRepository folderRepository;

  List<Folder> _folders = [];
  Folder? _selectedFolder;

  FoldersController({required this.folderRepository});

  List<Folder> get folders => _folders;
  Folder? get selectedFolder => _selectedFolder;

  Future<void> loadFolders() async {
    _folders = (await folderRepository.getAllFolders()).toList();
    _selectedFolder = null;
    notifyListeners();
  }

  /// Сменить активную папку. Очищает выбор — загрузку списка сниппетов
  /// под новую папку делает координатор ([AppController]).
  void selectFolder(Folder? folder) {
    _selectedFolder = folder;
    notifyListeners();
  }

  Future<Folder> createFolder(String initialName, {String? parentId}) async {
    String newName = '$initialName 1';
    int counter = 1;

    while (_folders.any((f) => f.name.toLowerCase() == newName.toLowerCase())) {
      counter++;
      newName = '$initialName $counter';
    }

    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      parentId: parentId,
      sortOrder: _folders.length,
    );

    await folderRepository.saveFolder(folder);
    _folders.add(folder);

    _selectedFolder = folder;

    notifyListeners();
    return folder;
  }

  Future<void> renameFolder(String id, String newName) async {
    final folder = await folderRepository.getFolderById(id);
    if (folder == null) return;

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == folder.name) return;

    final updated = folder.copyWith(name: trimmedName);
    await folderRepository.saveFolder(updated);

    final index = _folders.indexWhere((f) => f.id == id);
    if (index >= 0) {
      _folders[index] = updated;
    }

    notifyListeners();
  }

  /// Удаление папки из хранилища и из локального списка.
  /// (Сцепленную с папкой зачистку сниппетов выполняет координатор.)
  Future<void> deleteFolder(String id) async {
    await folderRepository.deleteFolder(id);
    _folders.removeWhere((f) => f.id == id);

    if (_selectedFolder?.id == id) {
      _selectedFolder = null;
    }

    notifyListeners();
  }
}
