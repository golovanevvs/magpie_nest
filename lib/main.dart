import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/highlight/languages_registry.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/theme/app_theme.dart';
import 'package:magpie_nest/features/folders/data/repositories/drift_folder_repository.dart';
import 'package:magpie_nest/features/snippets/data/repositories/drift_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';

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

  const supported = ['en', 'ru'];
  final systemLocale = PlatformDispatcher.instance.locale;
  final initialLocale = supported.contains(systemLocale.languageCode)
      ? Locale(systemLocale.languageCode)
      : const Locale('en');

  runApp(
    MagpieNestApp(appController: appController, initialLocale: initialLocale),
  );
}

class MagpieNestApp extends StatefulWidget {
  final AppController appController;
  final Locale initialLocale;

  const MagpieNestApp({
    super.key,
    required this.appController,
    required this.initialLocale,
  });

  @override
  State<MagpieNestApp> createState() => _MagpieNestAppState();
}

class _MagpieNestAppState extends State<MagpieNestApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void _handleThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _handleLocaleChanged(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie Nest',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      locale: _locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('ru')],

      home: MainScreen(
        controller: widget.appController,
        themeMode: _themeMode,
        onThemeModeChanged: _handleThemeModeChanged,
        currentLocale: _locale,
        onLocaleChanged: _handleLocaleChanged,
      ),
    );
  }
}
