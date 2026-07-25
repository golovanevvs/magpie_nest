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
/// - The user folder tree with nested indentation.
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
    final folders = _filterFolders(widget.controller.folders);

    if (folders.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.sidebarNoFolders,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) =>
          _buildFolderItem(context, folders[index]),
    );
  }

  List<Folder> _filterFolders(List<Folder> folders) {
    if (_searchQuery.isEmpty) return folders;

    return folders
        .where((folder) => folder.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Widget _buildFolderItem(BuildContext context, Folder folder) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = _editingFolderId == folder.id;
    final isSelected = widget.controller.selectedFolder?.id == folder.id;
    final indentation = folder.isRoot ? 0.0 : 24.0;

    if (isEditing) {
      return Padding(
        padding: EdgeInsets.only(
          left: indentation + 8,
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

    return GestureDetector(
      onDoubleTap: () => _startEditing(folder),
      child: _SidebarItem(
        icon: Icons.folder,
        label: folder.name,
        selected: isSelected,
        indent: indentation,
        onTap: () => widget.controller.selectFolder(folder),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              tooltip: l10n.buttonRename,
              onPressed: () => _startEditing(folder),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 16),
              tooltip: l10n.buttonDelete,
              onPressed: () => _confirmDelete(context, folder),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
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

/// Reusable sidebar list item with optional indentation and trailing actions.
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double indent;
  final Widget? trailing;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.indent = 0,
    this.trailing,
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
      dense: true,
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(51),
      contentPadding: EdgeInsets.only(left: 16 + indent, right: 8),
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      trailing: trailing,
    );
  }
}
