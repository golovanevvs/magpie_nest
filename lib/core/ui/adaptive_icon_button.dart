import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';

class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.compact = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onPressed,
        child: icon,
      );
    }

    return IconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: compact ? VisualDensity.compact : null,
      padding: compact ? EdgeInsets.zero : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 28, minHeight: 28)
          : null,
    );
  }
}
