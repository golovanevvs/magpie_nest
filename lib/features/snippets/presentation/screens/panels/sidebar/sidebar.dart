import 'package:flutter/material.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folder_tree.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/library_header.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/search_field.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/virtual_folders.dart';

/// Sidebar panel.
///
/// Contains:
/// - A search field to filter folders.
/// - Virtual folders: All Snippets, Inbox, Favorites, Trash.
/// - A "Library" header with a button to add new folders.
/// - The user folder tree with nested indentation and expand/collapse.
class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final AppController controller;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.controller,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _searchQuery = '';
  String? _editingFolderId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<StartFolderEditNotification>(
      onNotification: (notification) {
        setState(() {
          _editingFolderId = notification.folderId;
        });
        return true;
      },
      child: Column(
        children: [
          SearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          VirtualFolders(controller: widget.controller),
          const Divider(height: 1),
          LibraryHeader(controller: widget.controller),
          const Divider(height: 1),
          Expanded(
            child: FolderTree(
              controller: widget.controller,
              searchQuery: _searchQuery,
              editingFolderId: _editingFolderId,
              onFinishEditing: () => setState(() => _editingFolderId = null),
            ),
          ),
        ],
      ),
    );
  }
}
