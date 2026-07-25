import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';

/// Navigation rail panel (Panel 1).
///
/// Displays main sections: Library, All Snippets, Favorites, Trash.
/// Calls [onDestinationSelected] when the user clicks on a destination.
class NavigationRailPanel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavigationRailPanel({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.folder_open),
          label: Text(l10n.navLibrary),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.all_inbox),
          label: Text(l10n.navAllSnippets),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.star),
          label: Text(l10n.navFavorites),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.delete),
          label: Text(l10n.navTrash),
        ),
      ],
    );
  }
}
