import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/extensions/first_where_or_null.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/sidebar_item.dart';

/// Folder tree with search, expand/collapse, rename, and context menu.
class FolderTree extends StatefulWidget {
  final AppController controller;
  final String searchQuery;
  final String? editingFolderId;
  final VoidCallback onFinishEditing;

  const FolderTree({
    super.key,
    required this.controller,
    required this.searchQuery,
    this.editingFolderId,
    required this.onFinishEditing,
  });

  @override
  State<FolderTree> createState() => _FolderTreeState();
}

class _FolderTreeState extends State<FolderTree> {
  final Set<String> _expandedFolderIds = {};

  @override
  Widget build(BuildContext context) {
    final rootFolders = _visibleFolders(widget.controller.folders);

    if (rootFolders.isEmpty && widget.searchQuery.isNotEmpty) {
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
    if (widget.searchQuery.isEmpty) {
      return folders.where((f) => f.isRoot).toList();
    }

    final matchedIds = <String>{};
    for (final folder in folders) {
      if (folder.name.toLowerCase().contains(widget.searchQuery)) {
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
    final isEditing = widget.editingFolderId == folder.id;
    final isSelected = widget.controller.selectedFolder?.id == folder.id;
    final children = _childFolders(folder);
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedFolderIds.contains(folder.id);
    final depth = _folderDepth(folder);

    if (isEditing) {
      return FolderEditField(
        folder: folder,
        depth: depth,
        onSubmitted: (name) {
          widget.controller.renameFolder(folder.id, name);
          widget.onFinishEditing();
        },
      );
    }

    return Column(
      children: [
        GestureDetector(
          onDoubleTap: () => _startEditing(folder),
          onSecondaryTapUp: (details) =>
              _showFolderContextMenu(context, folder, details.globalPosition),
          child: SidebarItem(
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

  void _startEditing(Folder folder) {
    StartFolderEditNotification(folder.id, folder.name).dispatch(context);
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
          onTap: () => _createSubFolder(folder.id),
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

  Future<void> _createSubFolder(String parentId) async {
    final l10n = AppLocalizations.of(context)!;
    final newFolder = await widget.controller.createFolder(
      l10n.defaultFolderName,
      parentId: parentId,
    );

    if (!mounted) return;
    setState(() {
      _expandedFolderIds.add(parentId);
    });

    if (!context.mounted) return;
    StartFolderEditNotification(newFolder.id, newFolder.name).dispatch(context);
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

/// Notification sent when the user should start editing a folder.
class StartFolderEditNotification extends Notification {
  final String folderId;
  final String initialName;

  const StartFolderEditNotification(this.folderId, this.initialName);
}

/// Inline folder rename text field.
class FolderEditField extends StatefulWidget {
  final Folder folder;
  final int depth;
  final ValueChanged<String> onSubmitted;

  const FolderEditField({
    super.key,
    required this.folder,
    required this.depth,
    required this.onSubmitted,
  });

  @override
  State<FolderEditField> createState() => _FolderEditFieldState();
}

class _FolderEditFieldState extends State<FolderEditField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.folder.name);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16 + widget.depth * 24,
        right: 8,
        top: 4,
        bottom: 4,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        style: const TextStyle(fontSize: 14),
        onSubmitted: (_) => widget.onSubmitted(_controller.text),
        onTapOutside: (_) => widget.onSubmitted(_controller.text),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusNode.requestFocus();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }
}
