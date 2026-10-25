import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

fluent.FluentThemeData fluentThemeOf(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return fluent.FluentThemeData(
    brightness: Theme.of(context).brightness,
    accentColor: fluent.AccentColor.swatch({
      'normal': colorScheme.primary,
    }),
  );
}
