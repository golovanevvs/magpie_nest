import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/folders/data/repositories/in_memory_folder_repository.dart';
import 'package:magpie_nest/features/snippets/data/repositories/in_memory_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';

// Import the generated localization class.
// Replace 'magpie_nest' if your package name in pubspec.yaml differs.
void main() {
  final folderRepository = InMemoryFolderRepository();
  final snippetRepository = InMemorySnippetRepository();

  final appController = AppController(
    folderRepository: folderRepository,
    snippetRepository: snippetRepository,
  );

  runApp(MagpieNestApp(appController: appController));
}

/// Root widget of the Magpie Nest application.
///
/// Configures localization, theming, and the initial route.
class MagpieNestApp extends StatelessWidget {
  final AppController appController;

  const MagpieNestApp({super.key, required this.appController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie Nest',

      // Localization delegates:
      // - AppLocalizations.delegate: our generated translations.
      // - Global*Localizations.delegate: built-in Material/Cupertino translations
      //   for standard widgets (e.g., DatePicker, Back button text).
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported locales must match the available .arb files in lib/core/l10n/.
      supportedLocales: const [Locale('en'), Locale('ru')],

      // Demo screen to verify that localization is working.
      home: MainScreen(controller: appController),
    );
  }
}
