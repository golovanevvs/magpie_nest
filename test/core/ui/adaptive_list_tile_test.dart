import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/ui/adaptive_list_tile.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(VoidCallback onTap, {bool selected = false}) {
    return MaterialApp(
      home: Scaffold(
        body: AdaptiveListTile(
          leading: const Icon(Icons.folder),
          title: const Text('Item'),
          selected: selected,
          dense: true,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('renders ListTile on android and handles taps', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(host(() => pressed = true));

    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.text('Item'));
    expect(pressed, isTrue);
  });

  testWidgets('renders hover row on windows and handles taps', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(host(() => pressed = true));

    expect(find.byType(fluent.HoverButton), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    await tester.tap(find.text('Item'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(pressed, isTrue);
  });

  testWidgets('renders tappable row on iOS and handles taps', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var pressed = false;

    await tester.pumpWidget(host(() => pressed = true));

    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(fluent.HoverButton), findsNothing);
    await tester.tap(find.text('Item'));
    expect(pressed, isTrue);
  });
}
