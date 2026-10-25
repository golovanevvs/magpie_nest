import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/ui/adaptive_icon_button.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/settings_screen.dart';

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
            constraints: const BoxConstraints(maxWidth: 780),
            title: Text(l10n.settingsTitle),
            content: SizedBox(width: 760, height: 560, child: settings),
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
          width: 760,
          height: 560,
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