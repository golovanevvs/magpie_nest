import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

/// Sidebar panel styled after massCode.
///
/// Contains:
/// - A search field to filter folders.
/// - Virtual folders: All Snippets, Inbox, Favorites, Trash.
/// - A "Library" header with a button to add new folders.
/// - The user folder tree with nested indentation and expand/collapse.
class SidebarPanel extends StatefulWidget {
  final int selectedIndex;
  final AppController controller;

  const SidebarPanel({
    super.key,
    required this.selectedIndex,
    required this.controller,
  });

  @override
  State<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<SidebarPanel> {
  String _searchQuery = '';
  String? _editingFolderId;
  final Set<String> _expandedFolderIds = {};
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(context),
        _buildVirtualFolders(context),
        const Divider(height: 1),
        _buildLibraryHeader(context),
        const Divider(height: 1),
        Expanded(child: _buildFolderTree(context)),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.sidebarSearchHint,
          prefixIcon: const Icon(Icons.search, size: 18),
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(fontSize: 14),
        onChanged: (value) =>
            setState(() => _searchQuery = value.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildVirtualFolders(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final section = widget.controller.activeSection;
    final selectedFolder = widget.controller.selectedFolder;

    return Column(
      children: [
        _SidebarItem(
          icon: Icons.all_inbox,
          label: l10n.navAllSnippets,
          selected: selectedFolder == null && section == SidebarSection.all,
          onTap: () => widget.controller.selectSection(SidebarSection.all),
        ),
        _SidebarItem(
          icon: Icons.inbox,
          label: l10n.sidebarInbox,
          selected: selectedFolder == null && section == SidebarSection.inbox,
          onTap: () => widget.controller.selectSection(SidebarSection.inbox),
        ),
        _SidebarItem(
          icon: Icons.star,
          label: l10n.navFavorites,
          selected: section == SidebarSection.favorites,
          onTap: () =>
              widget.controller.selectSection(SidebarSection.favorites),
        ),
        _SidebarItem(
          icon: Icons.delete,
          label: l10n.navTrash,
          selected: section == SidebarSection.trash,
          onTap: () => widget.controller.selectSection(SidebarSection.trash),
        ),
      ],
    );
  }

  Widget _buildLibraryHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.navLibrary,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: l10n.buttonNewFolder,
            onPressed: () => _createFolderAndSelect(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTree(BuildContext context) {
    final rootFolders = _visibleFolders(widget.controller.folders);

    if (rootFolders.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.sidebarNoFolders,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      itemCount: rootFolders.length,
      itemBuilder: (context, index) =>
          _buildFolderItem(context, rootFolders[index]),
    );
  }

  List<Folder> _visibleFolders(List<Folder> folders) {
    if (_searchQuery.isEmpty) {
      return folders.where((f) => f.isRoot).toList();
    }

    final matchedIds = <String>{};
    for (final folder in folders) {
      if (folder.name.toLowerCase().contains(_searchQuery)) {
        matchedIds.add(folder.id);
      }
    }

    return folders
        .where(
          (folder) =>
              folder.isRoot && _isVisibleInSearch(folder, folders, matchedIds),
        )
        .toList();
  }

  bool _isVisibleInSearch(
    Folder folder,
    List<Folder> allFolders,
    Set<String> matchedIds,
  ) {
    if (matchedIds.contains(folder.id)) return true;
    final children = allFolders.where((f) => f.parentId == folder.id);
    for (final child in children) {
      if (_isVisibleInSearch(child, allFolders, matchedIds)) return true;
    }
    return false;
  }

  Widget _buildFolderItem(BuildContext context, Folder folder) {
    final isEditing = _editingFolderId == folder.id;
    final isSelected = widget.controller.selectedFolder?.id == folder.id;
    final children = _childFolders(folder);
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedFolderIds.contains(folder.id);
    final depth = _folderDepth(folder);

    if (isEditing) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16 + depth * 24,
          right: 8,
          top: 4,
          bottom: 4,
        ),
        child: TextField(
          controller: _editController,
          focusNode: _editFocusNode,
          autofocus: true,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          style: const TextStyle(fontSize: 14),
          onSubmitted: (_) => _finishEditing(folder.id),
          onTapOutside: (_) => _finishEditing(folder.id),
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onDoubleTap: () => _startEditing(folder),
          onSecondaryTapUp: (details) =>
              _showFolderContextMenu(context, folder, details.globalPosition),
          child: _SidebarItem(
            icon: Icons.folder,
            label: folder.name,
            selected: isSelected,
            indent: depth * 24,
            expandIcon: hasChildren
                ? isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.chevron_right
                : null,
            onTap: () => widget.controller.selectFolder(folder),
            onExpandTap: hasChildren
                ? () => _toggleFolderExpansion(folder.id)
                : null,
          ),
        ),
        if (isExpanded)
          ...children.map((child) => _buildFolderItem(context, child)),
      ],
    );
  }

  List<Folder> _childFolders(Folder parent) {
    return widget.controller.folders
        .where((f) => f.parentId == parent.id)
        .toList();
  }

  int _folderDepth(Folder folder) {
    var depth = 0;
    var current = folder;
    while (current.parentId != null) {
      final parent = widget.controller.folders.firstWhereOrNull(
        (f) => f.id == current.parentId,
      );
      if (parent == null) break;
      depth++;
      current = parent;
    }
    return depth;
  }

  void _toggleFolderExpansion(String folderId) {
    setState(() {
      if (_expandedFolderIds.contains(folderId)) {
        _expandedFolderIds.remove(folderId);
      } else {
        _expandedFolderIds.add(folderId);
      }
    });
  }

  void _showFolderContextMenu(
    BuildContext context,
    Folder folder,
    Offset position,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem<void>(
          onTap: () => _createSubFolderAndSelect(context, folder.id),
          child: Text(l10n.contextMenuNewFolder),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () => _startEditing(folder),
          child: Text(l10n.contextMenuRename),
        ),
        PopupMenuItem<void>(
          onTap: () => _confirmDelete(context, folder),
          child: Text(l10n.buttonDelete),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(onTap: () {}, child: Text(l10n.contextMenuSetIcon)),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () {},
          child: Text(l10n.contextMenuDefaultLanguage),
        ),
      ],
    );
  }

  Future<void> _createFolderAndSelect(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final newFolder = await widget.controller.createFolder(l10n.untitledFolder);

    setState(() {
      _editingFolderId = newFolder.id;
      _editController.text = newFolder.name;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  Future<void> _createSubFolderAndSelect(
    BuildContext context,
    String parentId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final newFolder = await widget.controller.createFolder(
      l10n.untitledFolder,
      parentId: parentId,
    );

    setState(() {
      _expandedFolderIds.add(parentId);
      _editingFolderId = newFolder.id;
      _editController.text = newFolder.name;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  void _startEditing(Folder folder) {
    setState(() {
      _editingFolderId = folder.id;
      _editController.text = folder.name;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  void _finishEditing(String folderId) {
    widget.controller.renameFolder(folderId, _editController.text);
    setState(() {
      _editingFolderId = null;
    });
  }

  Future<void> _confirmDelete(BuildContext context, Folder folder) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogDeleteFolderTitle),
        content: Text(l10n.dialogDeleteFolderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.dialogDelete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await widget.controller.deleteFolder(folder.id);
    }
  }
}

/// Reusable sidebar list item with optional indentation and expand icon.
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double indent;
  final IconData? expandIcon;
  final VoidCallback? onExpandTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.indent = 0,
    this.expandIcon,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        size: 18,
        color: selected ? colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: selected ? colorScheme.primary : null,
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      minLeadingWidth: 0,
      dense: true,
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(51),
      contentPadding: EdgeInsets.only(left: 16 + indent, right: 8),
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      trailing: expandIcon != null
          ? GestureDetector(
              onTap: onExpandTap,
              child: Icon(
                expandIcon,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );
  }
}

extension _FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
