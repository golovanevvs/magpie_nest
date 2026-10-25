import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/ui/adaptive_list_tile.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double indent;
  final IconData? expandIcon;
  final VoidCallback? onExpandTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.indent = 0,
    this.expandIcon,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdaptiveListTile(
      leading: Icon(
        icon,
        size: 18,
        color: selected ? colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: selected ? colorScheme.primary : null,
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      dense: true,
      selected: selected,
      contentPadding: EdgeInsets.only(left: 16 + indent, right: 8),
      onTap: onTap,
      trailing: expandIcon != null
          ? GestureDetector(
              onTap: onExpandTap,
              child: Icon(
                expandIcon,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );
  }
}
