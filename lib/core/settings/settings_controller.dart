import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _themeModeKey = 'themeMode';
  static const _localeKey = 'locale';

  static const _supportedLocales = ['en', 'ru'];
  static const _defaultLocale = Locale('en');

  final SharedPreferences _prefs;
  ThemeMode _themeMode;
  Locale _locale;

  SettingsController(SharedPreferences prefs)
    : _prefs = prefs,
      _themeMode = _readThemeMode(prefs),
      _locale = _readLocale(prefs);

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  static ThemeMode _readThemeMode(SharedPreferences prefs) {
    final stored = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  static Locale _readLocale(SharedPreferences prefs) {
    final stored = prefs.getString(_localeKey);
    if (stored != null && _supportedLocales.contains(stored)) {
      return Locale(stored);
    }

    final system = PlatformDispatcher.instance.locale;
    if (_supportedLocales.contains(system.languageCode)) {
      return Locale(system.languageCode);
    }

    return _defaultLocale;
  }
}
