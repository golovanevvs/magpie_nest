import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/ui/adaptive_icon_button.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders material IconButton on android and handles taps', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveIconButton(
          icon: const Icon(Icons.add),
          onPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);
    await tester.tap(find.byType(AdaptiveIconButton));
    expect(pressed, isTrue);
  });

  testWidgets('renders CupertinoButton on iOS and handles taps', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveIconButton(
          icon: const Icon(Icons.add),
          onPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.byType(cupertino.CupertinoButton), findsOneWidget);
    await tester.tap(find.byType(AdaptiveIconButton));
    expect(pressed, isTrue);
  });
}
