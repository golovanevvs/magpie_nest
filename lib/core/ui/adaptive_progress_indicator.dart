import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({super.key, this.value, this.strokeWidth});

  final double? value;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluentChrome(
        context,
        child: fluent.ProgressRing(
          value: value == null ? null : value! * 100,
          strokeWidth: strokeWidth ?? 4.5,
        ),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      if (value == null) return const cupertino.CupertinoActivityIndicator();
      return CircularProgressIndicator(value: value, strokeWidth: strokeWidth);
    }

    return CircularProgressIndicator(value: value, strokeWidth: strokeWidth);
  }
}

class AdaptiveLinearProgressIndicator extends StatelessWidget {
  const AdaptiveLinearProgressIndicator({
    super.key,
    this.value,
    this.minHeight,
  });

  final double? value;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluentChrome(
        context,
        child: fluent.ProgressBar(
          value: value == null ? null : value! * 100,
          strokeWidth: minHeight ?? 4.5,
        ),
      );
    }

    return LinearProgressIndicator(value: value, minHeight: minHeight);
  }
}
