import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/platform/design_language.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('designLanguageFor maps windows to fluent', () {
    expect(designLanguageFor(TargetPlatform.windows), DesignLanguage.fluent);
  });

  test('designLanguageFor maps iOS to cupertino', () {
    expect(designLanguageFor(TargetPlatform.iOS), DesignLanguage.cupertino);
  });

  test('designLanguageFor maps macOS to cupertino', () {
    expect(designLanguageFor(TargetPlatform.macOS), DesignLanguage.cupertino);
  });

  test('designLanguageFor maps android to material', () {
    expect(designLanguageFor(TargetPlatform.android), DesignLanguage.material);
  });

  test('designLanguageFor maps fuchsia to material', () {
    expect(designLanguageFor(TargetPlatform.fuchsia), DesignLanguage.material);
  });

  test('designLanguageFor maps linux to material', () {
    expect(designLanguageFor(TargetPlatform.linux), DesignLanguage.material);
  });
}
