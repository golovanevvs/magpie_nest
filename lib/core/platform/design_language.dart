import 'package:flutter/foundation.dart';

enum DesignLanguage { material, cupertino, fluent }

DesignLanguage designLanguageFor(TargetPlatform platform) {
  return switch (platform) {
    TargetPlatform.windows => DesignLanguage.fluent,
    TargetPlatform.iOS || TargetPlatform.macOS => DesignLanguage.cupertino,
    TargetPlatform.android ||
    TargetPlatform.fuchsia ||
    TargetPlatform.linux => DesignLanguage.material,
  };
}
