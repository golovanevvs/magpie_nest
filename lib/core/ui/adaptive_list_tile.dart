import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveListTile extends StatefulWidget {
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
  State<AdaptiveListTile> createState() => _AdaptiveListTileState();
}

class _AdaptiveListTileState extends State<AdaptiveListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FluentTheme(
        data: fluentThemeOf(context),
        child: fluent.HoverButton(
          onPressed: widget.onTap,
          builder: (hoverContext, states) {
            final fluentTheme = fluent.FluentTheme.of(hoverContext);
            final Color? backgroundColor;
            if (widget.selected) {
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
      final Color? backgroundColor;
      if (widget.selected) {
        backgroundColor = cupertino.CupertinoDynamicColor.resolve(
          cupertino.CupertinoColors.systemFill,
          context,
        );
      } else if (_hovered && widget.onTap != null) {
        backgroundColor = cupertino.CupertinoDynamicColor.resolve(
          cupertino.CupertinoColors.tertiarySystemFill,
          context,
        );
      } else {
        backgroundColor = null;
      }
      return MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            constraints: BoxConstraints(minHeight: widget.dense ? 36 : 44),
            color: backgroundColor,
            child: _buildRow(),
          ),
        ),
      );
    }

    return ListTile(
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: widget.trailing,
      selected: widget.selected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha(51),
      dense: widget.dense,
      minLeadingWidth: 0,
      contentPadding: widget.contentPadding,
      visualDensity: VisualDensity.compact,
      onTap: widget.onTap,
    );
  }

  Widget _buildRow() {
    return Padding(
      padding:
          widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.dense ? 8 : 10),
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [widget.title, ?widget.subtitle],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
