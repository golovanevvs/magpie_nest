import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

/// Main screen with a four-panel layout (similar to massCode).
///
/// Layout structure:
/// 1. Navigation Rail (leftmost) - switches between Library, All Snippets, Favorites, Trash
/// 2. Sidebar - shows folders (in Library mode) or section info
/// 3. Snippet List - shows snippets in the selected folder/section
/// 4. Snippet Viewer (rightmost) - displays the selected snippet's content
class MainScreen extends StatefulWidget {
  final AppController controller;

  const MainScreen({super.key, required this.controller});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0=Library, 1=All Snippets, 2=Favorites, 3=Trash

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panel 1: Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _handleNavigationChange(index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.folder_open),
                label: Text(AppLocalizations.of(context)!.navLibrary),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.all_inbox),
                label: Text(AppLocalizations.of(context)!.navAllSnippets),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star),
                label: Text(AppLocalizations.of(context)!.navFavorites),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delete),
                label: Text(AppLocalizations.of(context)!.navTrash),
              ),
            ],
          ),
          const VerticalDivider(width: 1),

          // Panel 2: Sidebar (folders or section info)
          SizedBox(width: 200, child: _buildSidebar()),
          const VerticalDivider(width: 1),

          // Panel 3: Snippet List
          SizedBox(width: 300, child: _buildSnippetList()),
          const VerticalDivider(width: 1),

          // Panel 4: Snippet Viewer
          Expanded(child: _buildSnippetViewer()),
        ],
      ),
    );
  }

  /// Handles navigation rail selection changes.
  ///
  /// Updates the controller's state based on the selected section.
  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0: // Library - show folders
        case 1: // All Snippets
          widget.controller.selectFolder(null);
          break;
        case 2: // Favorites
          widget.controller.loadFavoriteSnippets();
          break;
        case 3: // Trash
          widget.controller.loadDeletedSnippets();
          break;
      }
    });
  }

  /// Builds the sidebar panel based on the current navigation selection.
  ///
  /// In Library mode, shows the folder tree.
  /// In other modes, shows section-specific information.
  Widget _buildSidebar() {
    return switch (_selectedIndex) {
      // Library mode - show folders
      0 => ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.all_inbox),
            title: Text(AppLocalizations.of(context)!.sidebarInbox),
            onTap: () => widget.controller.selectFolder(null),
          ),
          const Divider(),
          ...widget.controller.folders.map((folder) {
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folder.name),
              selected: widget.controller.selectedFolder?.id == folder.id,
              onTap: () =>
                  setState(() => widget.controller.selectFolder(folder)),
            );
          }),
        ],
      ),

      // Favorites section
      2 => Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context)!.sidebarFavorites,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Trash section
      3 => Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context)!.sidebarTrash,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // All other cases (e.g., 1 - All Snippets)
      // Return an empty widget to hide the sidebar
      _ => const SizedBox.shrink(),
    };
  }

  /// Builds the snippet list panel.
  ///
  /// Displays all snippets from the current selection (folder or section).
  Widget _buildSnippetList() {
    final snippets = widget.controller.snippets;

    if (snippets.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.listNoSnippets));
    }

    return ListView.builder(
      itemCount: snippets.length,
      itemBuilder: (context, index) {
        final snippet = snippets[index];
        return ListTile(
          title: Text(snippet.name),
          subtitle: Text(snippet.language),
          leading: Icon(_getLanguageIcon(snippet.language)),
          selected: widget.controller.selectedSnippet?.id == snippet.id,
          onTap: () => setState(() => widget.controller.selectSnippet(snippet)),
        );
      },
    );
  }

  /// Returns an appropriate icon for the given programming language.
  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return Icons.code;
      case 'go':
        return Icons.code;
      case 'typescript':
      case 'javascript':
        return Icons.code;
      default:
        return Icons.text_snippet;
    }
  }

  /// Builds the snippet viewer panel.
  ///
  /// Displays the selected snippet's name, language, tags, and content.
  /// Shows a placeholder when no snippet is selected.
  Widget _buildSnippetViewer() {
    final snippet = widget.controller.selectedSnippet;

    if (snippet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.viewerSelectSnippet),
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
              IconButton(
                icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => setState(
                  () => widget.controller.toggleFavorite(snippet.id),
                ),
              ),
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
              Chip(label: Text(snippet.language)),
              ...snippet.tags.map((tag) => Chip(label: Text(tag))),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  snippet.content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the snippet.
  ///
  /// If the user confirms, calls [AppController.deleteSnippet].
  Future<void> _confirmDeleteSnippet(
    BuildContext context,
    Snippet snippet,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogDeleteTitle),
        content: Text(l10n.dialogDeleteMessage),
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
      widget.controller.deleteSnippet(snippet.id);
    }
  }
}
