import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/theme/app_theme.dart';
import 'package:magpie_nest/features/folders/data/repositories/in_memory_folder_repository.dart';
import 'package:magpie_nest/features/snippets/data/repositories/in_memory_snippet_repository.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/main_screen.dart';

void main() {
  final folderRepository = InMemoryFolderRepository();
  final snippetRepository = InMemorySnippetRepository();

  final appController = AppController(
    folderRepository: folderRepository,
    snippetRepository: snippetRepository,
  );

  runApp(MagpieNestApp(appController: appController));
}

class MagpieNestApp extends StatelessWidget {
  final AppController appController;

  const MagpieNestApp({super.key, required this.appController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie Nest',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('ru')],

      home: MainScreen(controller: appController),
    );
  }
}
