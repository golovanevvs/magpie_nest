import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

/// Snippet list panel (Panel 3).
///
/// Displays all snippets from the current selection (folder or section).
/// Includes a button to create a new snippet.
class SnippetList extends StatelessWidget {
  final AppController controller;

  const SnippetList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final snippets = controller.snippets;
    final l10n = AppLocalizations.of(context)!;

    if (snippets.isEmpty) {
      return Center(child: Text(l10n.listNoSnippets));
    }

    return Column(
      children: [
        // Header with "New Snippet" button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  controller.createDefaultSnippet(l10n.defaultSnippetName),
              icon: const Icon(Icons.add),
              label: Text(l10n.buttonNewSnippet),
            ),
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

/// A two-line snippet card in the style of massCode:
/// - first line: snippet name
/// - second line: folder name + update date (smaller, muted color)
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
