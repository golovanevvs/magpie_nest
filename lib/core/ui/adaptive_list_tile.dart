import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveListTile extends StatelessWidget {
  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.dense = false,
    this.contentPadding,
    this.onTap,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool selected;
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FluentTheme(
        data: fluentThemeOf(context),
        child: fluent.HoverButton(
          onPressed: onTap,
          builder: (hoverContext, states) {
            final fluentTheme = fluent.FluentTheme.of(hoverContext);
            final Color? backgroundColor;
            if (selected) {
              backgroundColor = fluentTheme.resources.subtleFillColorTertiary;
            } else if (states.contains(WidgetState.pressed)) {
              backgroundColor = fluentTheme.resources.subtleFillColorTertiary;
            } else if (states.contains(WidgetState.hovered)) {
              backgroundColor = fluentTheme.resources.subtleFillColorSecondary;
            } else {
              backgroundColor = null;
            }
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildRow(),
            );
          },
        ),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          color: selected
              ? cupertino.CupertinoDynamicColor.resolve(
                  cupertino.CupertinoColors.systemFill,
                  context,
                )
              : null,
          child: _buildRow(),
        ),
      );
    }

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      selected: selected,
      selectedTileColor:
          Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
      dense: dense,
      minLeadingWidth: 0,
      contentPadding: contentPadding,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
    );
  }

  Widget _buildRow() {
    return Padding(
      padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 8 : 10),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title,
                  ?subtitle,
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
