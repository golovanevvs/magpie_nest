import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:magpie_nest/core/constants/breakpoints.dart';
import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/ui/adaptive_icon_button.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/settings_screen.dart';

Future<void> showSettings(
  BuildContext context, {
  required CloudConnectionController cloud,
  required SyncController sync,
  required Locale currentLocale,
  required ThemeMode currentThemeMode,
  required ValueChanged<Locale> onLocaleChanged,
  required ValueChanged<ThemeMode> onThemeModeChanged,
  SettingsSection initialSection = SettingsSection.language,
}) {
  final mode = adaptiveLayoutFor(MediaQuery.sizeOf(context).width);
  if (mode == AdaptiveLayout.compact) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsPage(
          cloud: cloud,
          sync: sync,
          currentLocale: currentLocale,
          currentThemeMode: currentThemeMode,
          onLocaleChanged: onLocaleChanged,
          onThemeModeChanged: onThemeModeChanged,
          initialSection: initialSection,
        ),
      ),
    );
  }
  return showSettingsDialog(
    context,
    cloud: cloud,
    sync: sync,
    currentLocale: currentLocale,
    currentThemeMode: currentThemeMode,
    onLocaleChanged: onLocaleChanged,
    onThemeModeChanged: onThemeModeChanged,
    initialSection: initialSection,
  );
}

Future<void> showSettingsDialog(
  BuildContext context, {
  required CloudConnectionController cloud,
  required SyncController sync,
  required Locale currentLocale,
  required ThemeMode currentThemeMode,
  required ValueChanged<Locale> onLocaleChanged,
  required ValueChanged<ThemeMode> onThemeModeChanged,
  SettingsSection initialSection = SettingsSection.language,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      final media = MediaQuery.of(dialogContext);
      final dialogWidth = math.min(760.0, media.size.width - 48);
      final dialogHeight = math.min(560.0, media.size.height - 96);
      final designLanguage = designLanguageFor(
        Theme.of(dialogContext).platform,
      );
      final settings = SettingsScreen(
        cloud: cloud,
        sync: sync,
        currentLocale: currentLocale,
        currentThemeMode: currentThemeMode,
        onLocaleChanged: onLocaleChanged,
        onThemeModeChanged: onThemeModeChanged,
        initialSection: initialSection,
      );

      if (designLanguage == DesignLanguage.fluent) {
        return fluentChrome(
          dialogContext,
          child: fluent.ContentDialog(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            title: Text(l10n.settingsTitle),
            content: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              // ContentDialog provides no Material ancestor (unlike Dialog),
              // so wrap the shared Material-based settings body explicitly.
              child: Material(type: MaterialType.transparency, child: settings),
            ),
            actions: [
              fluent.Button(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.dialogClose),
              ),
            ],
          ),
        );
      }

      return Dialog(
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.settingsTitle,
                        style: Theme.of(dialogContext).textTheme.titleMedium,
                      ),
                    ),
                    AdaptiveIconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: settings),
            ],
          ),
        ),
      );
    },
  );
}

class _SettingsPage extends StatelessWidget {
  final CloudConnectionController cloud;
  final SyncController sync;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final SettingsSection initialSection;

  const _SettingsPage({
    required this.cloud,
    required this.sync,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    this.initialSection = SettingsSection.language,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SettingsScreen(
        cloud: cloud,
        sync: sync,
        currentLocale: currentLocale,
        currentThemeMode: currentThemeMode,
        onLocaleChanged: onLocaleChanged,
        onThemeModeChanged: onThemeModeChanged,
        initialSection: initialSection,
      ),
    );
  }
}
