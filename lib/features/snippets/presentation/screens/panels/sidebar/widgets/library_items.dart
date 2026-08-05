import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/sidebar_item.dart';

class LibraryItems extends StatelessWidget {
  final AppController controller;

  const LibraryItems({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final section = controller.activeSection;
    final selectedFolder = controller.selectedFolder;

    return Column(
      children: [
        SidebarItem(
          icon: Icons.inbox,
          label: l10n.sidebarInbox,
          selected: selectedFolder == null && section == SidebarSection.inbox,
          onTap: () => controller.selectSection(SidebarSection.inbox),
        ),
        SidebarItem(
          icon: Icons.star,
          label: l10n.navFavorites,
          selected: section == SidebarSection.favorites,
          onTap: () => controller.selectSection(SidebarSection.favorites),
        ),
        SidebarItem(
          icon: Icons.all_inbox,
          label: l10n.navAllSnippets,
          selected: selectedFolder == null && section == SidebarSection.all,
          onTap: () => controller.selectSection(SidebarSection.all),
        ),
        SidebarItem(
          icon: Icons.delete,
          label: l10n.navTrash,
          selected: section == SidebarSection.trash,
          onTap: () => controller.selectSection(SidebarSection.trash),
        ),
      ],
    );
  }
}
