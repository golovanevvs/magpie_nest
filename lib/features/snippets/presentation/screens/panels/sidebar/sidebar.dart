import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folder_tree.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/folders_header.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/library_items.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/search_field.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/sidebar_section_header.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/tags_list.dart';

/// Sidebar panel.
///
/// Contains:
/// - A search field to filter folders.
/// - Library items: Inbox, Favorites, All Snippets, Trash.
/// - A "Folders" section with a button to add new folders.
/// - The user folder tree with nested indentation and expand/collapse.
/// - A "Tags" section with tags from the current snippets.
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
  static const double _tagsPanelMinHeight = 80;
  static const double _tagsPanelMaxHeight = 320;
  static const double _tagsPanelDefaultHeight = 160;
  static const double _tagsBottomOffset = 8;

  String _searchQuery = '';
  String? _editingFolderId;
  double _tagsPanelHeight = _tagsPanelDefaultHeight;
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
          _buildResizeHandle(),
          SidebarSectionHeader(title: l10n.sidebarTags),
          Padding(
            padding: const EdgeInsets.only(bottom: _tagsBottomOffset),
            child: SizedBox(
              width: double.infinity,
              height: _tagsPanelHeight,
              child: TagsList(controller: widget.controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          setState(() {
            _tagsPanelHeight = (_tagsPanelHeight - details.delta.dy).clamp(
              _tagsPanelMinHeight,
              _tagsPanelMaxHeight,
            );
          });
        },
        child: const Divider(height: 8, thickness: 1),
      ),
    );
  }
}
