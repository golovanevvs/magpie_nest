import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/confirmation_dialog.dart';

class SnippetList extends StatelessWidget {
  final AppController controller;

  const SnippetList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final snippets = controller.snippets;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Header with "New Snippet" button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => controller.createDefaultSnippet(
                    l10n.defaultSnippetName,
                    defaultFragmentBaseName: l10n.fragmentNameBase,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.buttonNewSnippet),
                ),
              ),
              if (controller.activeSection == SidebarSection.trash) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: l10n.buttonEmptyTrash,
                  onPressed: () => _confirmEmptyTrash(context, controller),
                ),
              ],
            ],
          ),
        ),
        // Snippet list
        Expanded(
          child: snippets.isEmpty
              ? Center(child: Text(l10n.listNoSnippets))
              : ListView.builder(
                  itemCount: snippets.length,
                  itemBuilder: (context, index) {
                    final snippet = snippets[index];
                    final selected =
                        controller.selectedSnippet?.id == snippet.id;
                    return _SnippetListItem(
                      snippet: snippet,
                      folders: controller.folders,
                      selected: selected,
                      onTap: () => controller.selectSnippet(snippet),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Future<void> _confirmEmptyTrash(
  BuildContext context,
  AppController controller,
) async {
  final l10n = AppLocalizations.of(context)!;
  final shouldEmpty = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: l10n.dialogEmptyTrashTitle,
      message: l10n.dialogEmptyTrashMessage,
      confirmLabel: l10n.buttonEmptyTrash,
    ),
  );
  if (shouldEmpty == true) {
    await controller.emptyTrash();
  }
}

class _SnippetListItem extends StatelessWidget {
  final Snippet snippet;
  final List<Folder> folders;
  final bool selected;
  final VoidCallback onTap;

  const _SnippetListItem({
    required this.snippet,
    required this.folders,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final folderName = _resolveFolderName(l10n);
    final formattedDate = DateFormat('dd.MM.yyyy').format(snippet.updatedAt);

    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(51),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      title: Text(
        snippet.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            snippet.isInbox ? Icons.inbox : Icons.folder,
            size: 12,
            color: subtitleColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              folderName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
          ),
          Text(
            formattedDate,
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
        ],
      ),
    );
  }

  String _resolveFolderName(AppLocalizations l10n) {
    if (snippet.isInbox) {
      return l10n.sidebarInbox;
    }
    final folder = folders
        .where((folder) => folder.id == snippet.folderId)
        .firstOrNull;
    return folder?.name ?? l10n.sidebarInbox;
  }
}
