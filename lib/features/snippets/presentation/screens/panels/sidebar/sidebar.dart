import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folder_tree.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folders_header.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/library_items.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/search_field.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/sidebar_section_header.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
          SidebarSectionHeader(title: l10n.sidebarLibrary),
          LibraryItems(controller: widget.controller),
          FoldersHeader(controller: widget.controller),
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
