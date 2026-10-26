import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_credentials_store.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/settings_dialog.dart';
import 'package:material_ui/material_ui.dart';

class _FakeCredentialsStore implements WebdavCredentialsStore {
  @override
  Future<WebdavCredentials?> read() async => null;

  @override
  Future<void> save(WebdavCredentials credentials) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  Future<CloudConnectionController> makeCloud() async {
    final cloud = CloudConnectionController(store: _FakeCredentialsStore());
    return cloud;
  }

  testWidgets('settings dialog renders its Material body on Windows', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final cloud = await makeCloud();
    final sync = SyncController(runner: () async {}, cloud: cloud);
    var locale = const Locale('en');
    var themeMode = ThemeMode.system;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showSettingsDialog(
                  context,
                  cloud: cloud,
                  sync: sync,
                  currentLocale: locale,
                  currentThemeMode: themeMode,
                  onLocaleChanged: (v) => locale = v,
                  onThemeModeChanged: (v) => themeMode = v,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsAtLeastNWidgets(3));
    expect(find.byType(DropdownMenu<Locale>), findsOneWidget);
    expect(find.text('English'), findsWidgets);
  });
}
