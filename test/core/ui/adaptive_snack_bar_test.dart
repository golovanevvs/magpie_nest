import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/ui/adaptive_snack_bar.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(void Function(BuildContext context) onShow) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => onShow(context),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows a Material SnackBar on android', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      host(
        (context) => showAdaptiveSnackBar(
          context,
          message: 'Copied',
          duration: const Duration(seconds: 1),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    expect(find.text('Copied'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Copied'), findsNothing);
  });

  testWidgets('shows a fluent InfoBar popup on windows and auto-dismisses', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      host(
        (context) => showAdaptiveSnackBar(
          context,
          message: 'Copied',
          duration: const Duration(seconds: 1),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.byType(fluent.InfoBar), findsOneWidget);
    expect(find.text('Copied'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(fluent.InfoBar), findsNothing);
    expect(find.text('Copied'), findsNothing);
  });
}
