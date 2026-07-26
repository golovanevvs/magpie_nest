import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/delete_confirmation_dialog.dart';

/// Snippet preview panel (Panel 4).
///
/// Displays the selected snippet's name, language, tags, and content
/// with syntax highlighting.
class SnippetPreview extends StatelessWidget {
  final int selectedIndex;
  final AppController controller;

  const SnippetPreview({
    super.key,
    required this.selectedIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final snippet = controller.selectedSnippet;
    final l10n = AppLocalizations.of(context)!;

    if (snippet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.viewerSelectSnippet),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  snippet.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (selectedIndex == 3)
                IconButton(
                  icon: const Icon(Icons.restore_from_trash),
                  tooltip: l10n.buttonRestore,
                  onPressed: () => controller.restoreSnippet(snippet.id),
                ),
              IconButton(
                icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => controller.toggleFavorite(snippet.id),
              ),
              if (selectedIndex != 3)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDeleteSnippet(context, snippet),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(snippet.activeFragment.language)),
              ...snippet.tags.map((tag) => Chip(label: Text(tag))),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildCodeViewer(context, snippet)),
        ],
      ),
    );
  }

  Widget _buildCodeViewer(BuildContext context, Snippet snippet) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF282C34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21252B),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  snippet.activeFragment.language,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                  tooltip: l10n.buttonCopy,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: snippet.activeFragment.content),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.snackbarCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: HighlightView(
                snippet.activeFragment.content,
                language: snippet.activeFragment.language,
                theme: atomOneDarkTheme,
                padding: const EdgeInsets.all(12),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSnippet(
    BuildContext context,
    Snippet snippet,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (shouldDelete == true) {
      controller.deleteSnippet(snippet.id);
    }
  }
}
