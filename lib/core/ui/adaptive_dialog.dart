import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveAlertDialog extends StatelessWidget {
  const AdaptiveAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FluentTheme(
        data: fluentThemeOf(context),
        child: fluent.ContentDialog(
          title: title,
          content: content,
          actions: actions,
        ),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actions,
      );
    }

    return AlertDialog(title: title, content: content, actions: actions);
  }
}

class AdaptiveDialogAction extends StatelessWidget {
  const AdaptiveDialogAction({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.Button(onPressed: onPressed, child: Text(label));
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoDialogAction(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return TextButton(onPressed: onPressed, child: Text(label));
  }
}

class AdaptiveFilledDialogAction extends StatelessWidget {
  const AdaptiveFilledDialogAction({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluent.FilledButton(onPressed: onPressed, child: Text(label));
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return cupertino.CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return FilledButton(onPressed: onPressed, child: Text(label));
  }
}

class AdaptiveConfirmationDialog extends StatelessWidget {
  const AdaptiveConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdaptiveAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AdaptiveDialogAction(
          label: l10n.dialogCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AdaptiveDialogAction(
          label: confirmLabel,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

Future<bool> showAdaptiveConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AdaptiveConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      );
    },
  );
  return result ?? false;
}
