import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FluentTheme(
        data: fluentThemeOf(context),
        child: fluent.Button(onPressed: onPressed, child: child),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoButton(
        onPressed: onPressed,
        sizeStyle: cupertino.CupertinoButtonSize.medium,
        child: child,
      );
    }

    return TextButton(onPressed: onPressed, child: child);
  }
}

class AdaptiveFilledButton extends StatelessWidget {
  const AdaptiveFilledButton({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FluentTheme(
        data: fluentThemeOf(context),
        child: fluent.FilledButton(onPressed: onPressed, child: child),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoButton.filled(
        onPressed: onPressed,
        sizeStyle: cupertino.CupertinoButtonSize.medium,
        child: child,
      );
    }

    return FilledButton(onPressed: onPressed, child: child);
  }
}

class AdaptiveOutlinedButton extends StatelessWidget {
  const AdaptiveOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FluentTheme(
        data: fluentThemeOf(context),
        child: fluent.OutlinedButton(onPressed: onPressed, child: child),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoButton.tinted(
        onPressed: onPressed,
        sizeStyle: cupertino.CupertinoButtonSize.medium,
        child: child,
      );
    }

    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
