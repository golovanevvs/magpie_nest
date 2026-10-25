import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/ui/adaptive_button.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders FilledButton on android and handles taps', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFilledButton(
            onPressed: () => pressed = true,
            child: const Text('Save'),
          ),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(pressed, isTrue);
  });

  testWidgets('renders fluent FilledButton on windows and handles taps', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFilledButton(
            onPressed: () => pressed = true,
            child: const Text('Save'),
          ),
        ),
      ),
    );

    expect(find.byType(fluent.FilledButton), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(pressed, isTrue);
  });

  testWidgets('renders tinted CupertinoButton on iOS and handles taps', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFilledButton(
            onPressed: () => pressed = true,
            child: const Text('Save'),
          ),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(fluent.FilledButton), findsNothing);
    await tester.tap(find.text('Save'));
    expect(pressed, isTrue);
  });
}
