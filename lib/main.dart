import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';

void main() {
  runApp(const MagpieNestApp());
}

class MagpieNestApp extends StatelessWidget {
  const MagpieNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie Nest',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('ru')],

      home: Scaffold(
        appBar: AppBar(
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
