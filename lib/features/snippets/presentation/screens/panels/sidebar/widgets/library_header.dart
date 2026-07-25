import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

/// Library header with a button to add a new folder.
class LibraryHeader extends StatelessWidget {
  final AppController controller;

  const LibraryHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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

  Future<void> _createFolderAndSelect(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final newFolder = await controller.createFolder(l10n.untitledFolder);

    if (!context.mounted) return;
    // Notify the parent that a new folder is being edited.
    FolderEditNotification(newFolder.id, newFolder.name).dispatch(context);
  }
}

/// Notification dispatched when the user starts editing a folder name.
class FolderEditNotification extends Notification {
  final String folderId;
  final String initialName;

  const FolderEditNotification(this.folderId, this.initialName);
}
