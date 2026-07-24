import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';

// Import the generated localization class.
// Replace 'magpie_nest' if your package name in pubspec.yaml differs.
void main() {
  runApp(const MagpieNestApp());
}

/// Root widget of the Magpie Nest application.
///
/// Configures localization, theming, and the initial route.
class MagpieNestApp extends StatelessWidget {
  const MagpieNestApp({super.key});

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
      home: Scaffold(
        appBar: AppBar(
          // Builder is needed here because MaterialApp creates the
          // localization context, so we cannot use AppLocalizations.of(context)
          // directly inside MaterialApp's build method.
          title: Builder(
            builder: (context) => Text(AppLocalizations.of(context)!.appTitle),
          ),
        ),
        body: const Center(
          child: Text('Localization is working! / Локализация работает!'),
        ),
      ),
    );
  }
}
