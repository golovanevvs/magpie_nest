import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/ui/adaptive_dropdown.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host({
    required void Function(String?) onChanged,
    required String value,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AdaptiveDropdown<String>(
          value: value,
          items: const [
            AdaptiveDropdownItem(value: 'dart', label: 'Dart'),
            AdaptiveDropdownItem(value: 'python', label: 'Python'),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  testWidgets('renders DropdownButton on android', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    String? selected;

    await tester.pumpWidget(
      host(value: 'dart', onChanged: (v) => selected = v),
    );

    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    await tester.tap(find.text('Dart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Python').last);
    await tester.pumpAndSettle();
    expect(selected, 'python');
  });

  testWidgets('renders ComboBox on windows', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      host(value: 'dart', onChanged: (_) {}),
    );

    expect(find.byType(fluent.ComboBox<String>), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(find.text('Dart'), findsOneWidget);
  });

  testWidgets('renders picker trigger on iOS and selects via popup', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    String? selected;

    await tester.pumpWidget(
      host(value: 'dart', onChanged: (v) => selected = v),
    );

    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(find.text('Dart'), findsOneWidget);

    await tester.tap(find.text('Dart'));
    await tester.pumpAndSettle();
    expect(find.byType(cupertino.CupertinoPicker), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });
}
