import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/ui/adaptive_text_field.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders Material TextField on android and handles input', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    var changed = '';
    String? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => changed = v,
            onSubmitted: (v) => submitted = v,
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(changed, 'abc');
    expect(submitted, 'abc');
  });

  testWidgets('renders fluent TextBox on windows and shows error text', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: const InputDecoration(
              labelText: 'Name',
              errorText: 'oops',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(fluent.TextBox), findsOneWidget);
    expect(find.text('oops'), findsOneWidget);
  });

  testWidgets('renders CupertinoTextField on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(fluent.TextBox), findsNothing);
    expect(find.byType(cupertino.CupertinoTextField), findsOneWidget);
  });

  testWidgets('renders borderless fluent TextBox without field chrome', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );

    final box = tester.widget<fluent.TextBox>(find.byType(fluent.TextBox));
    const states = <WidgetState>{};
    expect(box.decoration!.resolve(states).border, Border());
    expect(box.decoration!.resolve(states).color, Colors.transparent);
    expect(box.foregroundDecoration!.resolve(states).border, Border());
  });

  testWidgets('renders borderless CupertinoTextField without the field box', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: const InputDecoration(
              hintText: 'Description',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: null,
          ),
        ),
      ),
    );

    final field = tester.widget<cupertino.CupertinoTextField>(
      find.byType(cupertino.CupertinoTextField),
    );
    expect(field.decoration, isNull);
    expect(field.padding, EdgeInsets.zero);
  });
}
