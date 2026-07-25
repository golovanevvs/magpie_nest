import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

/// Sidebar panel (Panel 2).
///
/// In Library mode, displays the folder tree.
/// In other modes, displays section-specific information.
class SidebarPanel extends StatelessWidget {
  final int selectedIndex;
  final AppController controller;

  const SidebarPanel({
    super.key,
    required this.selectedIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return switch (selectedIndex) {
      0 => _buildLibrarySidebar(context),
      2 => _buildFavoritesSidebar(context),
      3 => _buildTrashSidebar(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLibrarySidebar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.all_inbox),
          title: Text(l10n.sidebarInbox),
          onTap: () => controller.selectFolder(null),
        ),
        const Divider(),
        ...controller.folders.map((folder) {
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(folder.name),
            selected: controller.selectedFolder?.id == folder.id,
            onTap: () => controller.selectFolder(folder),
          );
        }),
      ],
    );
  }

  Widget _buildFavoritesSidebar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        l10n.sidebarFavorites,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrashSidebar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        l10n.sidebarTrash,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
