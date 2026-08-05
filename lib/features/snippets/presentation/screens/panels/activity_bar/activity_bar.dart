import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';

class ActivityBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const ActivityBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).navigationRailTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            context: context,
            index: 0,
            icon: Icons.code,
            label: l10n.navSnippets,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNavButton(
              context: context,
              index: 1,
              icon: Icons.settings,
              label: l10n.navSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Tooltip(
      message: label,
      child: InkResponse(
        onTap: () => onDestinationSelected(index),
        mouseCursor: SystemMouseCursors.click,
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
