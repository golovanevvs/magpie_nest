import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/create_snippet_dialog.dart';

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
              onPressed: () => _showCreateDialog(context),
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
                    return ListTile(
                      title: Text(snippet.name),
                      subtitle: Text(snippet.language),
                      leading: Icon(_getLanguageIcon(snippet.language)),
                      selected: controller.selectedSnippet?.id == snippet.id,
                      onTap: () => controller.selectSnippet(snippet),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final snippet = await showDialog<Snippet>(
      context: context,
      builder: (context) => const CreateSnippetDialog(),
    );

    if (snippet != null) {
      controller.createSnippet(snippet);
    }
  }

  /// Returns an appropriate icon for the given programming language.
  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
      case 'go':
      case 'typescript':
      case 'javascript':
        return Icons.code;
      default:
        return Icons.text_snippet;
    }
  }
}
