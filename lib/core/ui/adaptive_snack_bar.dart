import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

void showAdaptiveSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  final designLanguage = designLanguageFor(Theme.of(context).platform);

  if (designLanguage == DesignLanguage.fluent) {
    _showFluentInfoBar(context, message: message, duration: duration);
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: duration));
}

OverlayEntry? _activeInfoBar;

void _showFluentInfoBar(
  BuildContext context, {
  required String message,
  required Duration duration,
}) {
  _closeActiveInfoBar();

  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (entryContext) => Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: fluentChrome(
          context,
          child: fluent.InfoBar(
            severity: fluent.InfoBarSeverity.info,
            title: Text(message),
            onClose: _closeActiveInfoBar,
          ),
        ),
      ),
    ),
  );

  _activeInfoBar = entry;
  overlay.insert(entry);
  Timer(duration, _closeActiveInfoBar);
}

void _closeActiveInfoBar() {
  final entry = _activeInfoBar;
  if (entry == null || !entry.mounted) return;
  _activeInfoBar = null;
  entry.remove();
}
