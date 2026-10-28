import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/database/app_database.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/settings/settings_controller.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/lazy_webdav_sync_repository.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/sync/sync_engine.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/core/theme/app_theme.dart';
import 'package:magpie_nest/features/folders/data/repositories/drift_folder_repository.dart';
import 'package:magpie_nest/features/snippets/data/repositories/drift_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final cloud = CloudConnectionController(
    store: SecureWebdavCredentialsStore(),
  );
  await cloud.load();

  final syncEngine = SyncEngine(
    db: database,
    syncRepository: LazyWebdavSyncRepository(
      store: SecureWebdavCredentialsStore(),
    ),
  );
  final sync = SyncController(
    runner: syncEngine.syncNow,
    cloud: cloud,
    purgeRunner: syncEngine.purgeRemote,
  );

  runApp(
    MagpieNestApp(
      appController: appController,
      settings: settings,
      cloud: cloud,
      sync: sync,
    ),
  );
}

class MagpieNestApp extends StatelessWidget {
  final AppController appController;
  final SettingsController settings;
  final CloudConnectionController cloud;
  final SyncController sync;

  const MagpieNestApp({
    super.key,
    required this.appController,
    required this.settings,
    required this.cloud,
    required this.sync,
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
            cloud: cloud,
            sync: sync,
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
