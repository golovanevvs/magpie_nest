import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/ui/adaptive_dialog.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester, {
    required TargetPlatform platform,
    required void Function(BuildContext context) onOpen,
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => onOpen(context),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders AlertDialog on android and returns true on confirm', (
    tester,
  ) async {
    Future<bool>? result;
    await openDialog(
      tester,
      platform: TargetPlatform.android,
      onOpen: (context) {
        result = showAdaptiveConfirmationDialog(
          context: context,
          title: 'Title',
          message: 'Message',
          confirmLabel: 'OK',
        );
      },
    );

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await result!, isTrue);
  });

  testWidgets('renders AlertDialog on android and returns false on cancel', (
    tester,
  ) async {
    Future<bool>? result;
    await openDialog(
      tester,
      platform: TargetPlatform.android,
      onOpen: (context) {
        result = showAdaptiveConfirmationDialog(
          context: context,
          title: 'Title',
          message: 'Message',
          confirmLabel: 'OK',
        );
      },
    );

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result!, isFalse);
  });

  testWidgets('renders CupertinoAlertDialog on iOS and returns true', (
    tester,
  ) async {
    Future<bool>? result;
    await openDialog(
      tester,
      platform: TargetPlatform.iOS,
      onOpen: (context) {
        result = showAdaptiveConfirmationDialog(
          context: context,
          title: 'Title',
          message: 'Message',
          confirmLabel: 'OK',
        );
      },
    );

    expect(find.byType(cupertino.CupertinoAlertDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await result!, isTrue);
  });

  testWidgets('renders ContentDialog on windows and returns true', (
    tester,
  ) async {
    Future<bool>? result;
    await openDialog(
      tester,
      platform: TargetPlatform.windows,
      onOpen: (context) {
        result = showAdaptiveConfirmationDialog(
          context: context,
          title: 'Title',
          message: 'Message',
          confirmLabel: 'OK',
        );
      },
    );

    expect(find.byType(fluent.ContentDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(await result!, isTrue);
  });
}
