import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/highlight/languages_registry.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/settings/settings_controller.dart';
import 'package:magpie_nest/core/theme/app_theme.dart';
import 'package:magpie_nest/features/folders/data/repositories/drift_folder_repository.dart';
import 'package:magpie_nest/features/snippets/data/repositories/drift_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLanguages();

  // Dev-only: wipe the database when the MAGPIE_NEST_RESET_DB flag is set
  await AppDatabase.resetForDevelopment();

  final database = AppDatabase();

  final folderRepository = DriftFolderRepository(database);
  final snippetRepository = DriftSnippetRepository(database);

  final appController = AppController(
    folderRepository: folderRepository,
    snippetRepository: snippetRepository,
  );

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsController(prefs);

  runApp(MagpieNestApp(appController: appController, settings: settings));
}

class MagpieNestApp extends StatelessWidget {
  final AppController appController;
  final SettingsController settings;

  const MagpieNestApp({
    super.key,
    required this.appController,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Magpie Nest',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: settings.locale,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [Locale('en'), Locale('ru')],

          home: MainScreen(
            controller: appController,
            themeMode: settings.themeMode,
            onThemeModeChanged: settings.setThemeMode,
            currentLocale: settings.locale,
            onLocaleChanged: settings.setLocale,
          ),
        );
      },
    );
  }
}
