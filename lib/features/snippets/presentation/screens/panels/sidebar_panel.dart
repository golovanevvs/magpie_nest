import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

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
  String? _editingFolderId;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.selectedIndex) {
      0 => _buildLibrarySidebar(context),
      2 => _buildFavoritesSidebar(context),
      3 => _buildTrashSidebar(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLibrarySidebar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                l10n.navLibrary,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: l10n.buttonNewFolder,
                onPressed: () => _createFolderAndSelect(context),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.all_inbox, size: 20),
          title: Text(l10n.sidebarInbox, style: const TextStyle(fontSize: 14)),
          dense: true,
          selected: widget.controller.selectedFolder == null,
          onTap: () => widget.controller.selectFolder(null),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.controller.folders.length,
            itemBuilder: (context, index) {
              final folder = widget.controller.folders[index];
              return _buildFolderItem(context, folder);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFolderItem(BuildContext context, Folder folder) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = _editingFolderId == folder.id;

    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          onTapOutside: (_) =>
              _finishEditing(folder.id), // Сохранение при клике вне
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: () => _startEditing(folder),
      child: ListTile(
        leading: const Icon(Icons.folder, size: 20),
        title: Text(folder.name, style: const TextStyle(fontSize: 14)),
        dense: true,
        selected: widget.controller.selectedFolder?.id == folder.id,
        onTap: () => widget.controller.selectFolder(folder),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              tooltip: l10n.buttonRename,
              onPressed: () => _startEditing(folder),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 16),
              tooltip: l10n.buttonDelete,
              onPressed: () => _confirmDelete(context, folder),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFolderAndSelect(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Передаём локализованное имя в контроллер
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

  Widget _buildFavoritesSidebar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context)!.sidebarFavorites,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrashSidebar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context)!.sidebarTrash,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
