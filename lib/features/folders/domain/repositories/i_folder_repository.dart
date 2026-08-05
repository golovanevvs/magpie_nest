import 'package:magpie_nest/features/folders/domain/models/folder.dart';

abstract class IFolderRepository {
  Future<List<Folder>> getAllFolders();
  Future<Folder?> getFolderById(String id);
  Future<void> saveFolder(Folder folder);
  Future<void> deleteFolder(String id);
}
