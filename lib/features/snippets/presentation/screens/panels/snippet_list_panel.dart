import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

/// Snippet list panel (Panel 3).
///
/// Displays all snippets from the current selection (folder or section).
class SnippetListPanel extends StatelessWidget {
  final AppController controller;

  const SnippetListPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final snippets = controller.snippets;
    final l10n = AppLocalizations.of(context)!;

    if (snippets.isEmpty) {
      return Center(child: Text(l10n.listNoSnippets));
    }

    return ListView.builder(
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
    );
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
