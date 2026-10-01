import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/confirmation_dialog.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/delete_confirmation_dialog.dart';

class SnippetHeader extends StatelessWidget {
  final AppController controller;
  final Snippet snippet;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final bool nameIsEmpty;
  final bool isAddingDescription;
  final TextEditingController descriptionController;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onCommitName;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onAddDescription;

  const SnippetHeader({
    super.key,
    required this.controller,
    required this.snippet,
    required this.nameController,
    required this.nameFocusNode,
    required this.nameIsEmpty,
    required this.isAddingDescription,
    required this.descriptionController,
    required this.onNameChanged,
    required this.onCommitName,
    required this.onDescriptionChanged,
    required this.onAddDescription,
  });

  Future<void> _confirmDeleteSnippet(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (shouldDelete == true) {
      controller.deleteSnippet(snippet.id);
    }
  }

  Future<void> _confirmDeleteForever(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: l10n.dialogDeleteForeverTitle,
        message: l10n.dialogDeleteForeverMessage,
        confirmLabel: l10n.buttonDeleteForever,
      ),
    );
    if (shouldDelete == true) {
      await controller.permanentlyDeleteSnippet(snippet.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasDescription =
        snippet.description != null && snippet.description!.isNotEmpty;
    final showDescriptionField = isAddingDescription || hasDescription;
    final showAddDescriptionButton = !isAddingDescription && !hasDescription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                focusNode: nameFocusNode,
                decoration: InputDecoration(
                  hintText: l10n.fieldSnippetName,
                  errorText: nameIsEmpty ? l10n.errorNameCannotBeEmpty : null,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
                onChanged: onNameChanged,
                onSubmitted: (_) => onCommitName(),
              ),
            ),
            if (controller.activeSection == SidebarSection.trash)
              IconButton(
                icon: const Icon(Icons.restore_from_trash),
                tooltip: l10n.buttonRestore,
                onPressed: () => controller.restoreSnippet(snippet.id),
              ),
            // Empty Trash Button
            if (controller.activeSection == SidebarSection.trash)
              IconButton(
                icon: const Icon(Icons.delete_forever_outlined),
                tooltip: l10n.buttonDeleteForever,
                onPressed: () => _confirmDeleteForever(context),
              ),
            // Add Description Button
            if (showAddDescriptionButton)
              IconButton(
                icon: const Icon(Icons.notes),
                tooltip: l10n.buttonAddDescription,
                onPressed: onAddDescription,
              ),
            // Add Fragment Button
            IconButton(
              icon: Icon(Icons.note_add_outlined),
              tooltip: l10n.buttonAddFragment,
              onPressed: () {
                controller.addFragment(snippet.id, l10n.fragmentNameBase);
              },
            ),
            // Favorite Button
            IconButton(
              icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border),
              tooltip: l10n.buttonFavorite,
              onPressed: () => controller.toggleFavorite(snippet.id),
            ),
            // Delete Button
            if (controller.activeSection != SidebarSection.trash)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.buttonDelete,
                onPressed: () => _confirmDeleteSnippet(context),
              ),
          ],
        ),
        if (showDescriptionField) ...[
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: l10n.fieldDescriptionHint,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onChanged: onDescriptionChanged,
          ),
        ],
      ],
    );
  }
}
