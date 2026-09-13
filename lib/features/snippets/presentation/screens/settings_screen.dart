import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedMenuIndex;
  late Locale _currentLocale;
  late ThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _selectedMenuIndex = 0;
    _currentLocale = widget.currentLocale;
    _currentThemeMode = widget.currentThemeMode;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocale != widget.currentLocale) {
      _currentLocale = widget.currentLocale;
    }
    if (oldWidget.currentThemeMode != widget.currentThemeMode) {
      _currentThemeMode = widget.currentThemeMode;
    }
  }

  void _handleLocaleChanged(Locale locale) {
    setState(() => _currentLocale = locale);
    widget.onLocaleChanged(locale);
  }

  void _handleThemeModeChanged(ThemeMode mode) {
    setState(() => _currentThemeMode = mode);
    widget.onThemeModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 220,
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.language),
                title: Text(l10n.settingsLanguage),
                selected: _selectedMenuIndex == 0,
                onTap: () => setState(() => _selectedMenuIndex = 0),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text(l10n.settingsTheme),
                selected: _selectedMenuIndex == 1,
                onTap: () => setState(() => _selectedMenuIndex = 1),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedMenuIndex) {
      case 0:
        return _LanguagePanel(
          currentLocale: _currentLocale,
          onLocaleChanged: _handleLocaleChanged,
        );
      case 1:
        return _ThemePanel(
          currentThemeMode: _currentThemeMode,
          onThemeModeChanged: _handleThemeModeChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const _LanguageSelector({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      key: ValueKey(currentLocale),
      initialSelection: currentLocale,
      onSelected: (Locale? value) {
        if (value != null) onLocaleChanged(value);
      },
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: Locale('en'), label: 'English'),
        DropdownMenuEntry(value: Locale('ru'), label: 'Русский'),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const _ThemeSelector({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RadioGroup(
      groupValue: currentThemeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) onThemeModeChanged(value);
      },
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeLight),
            value: ThemeMode.light,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeDark),
            value: ThemeMode.dark,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeSystem),
            value: ThemeMode.system,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _LanguagePanel extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const _LanguagePanel({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: AppLocalizations.of(context)!.settingsLanguage),
        const SizedBox(height: 8),
        _LanguageSelector(
          currentLocale: currentLocale,
          onLocaleChanged: onLocaleChanged,
        ),
      ],
    );
  }
}

class _ThemePanel extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const _ThemePanel({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: AppLocalizations.of(context)!.settingsTheme),
        const SizedBox(height: 8),
        _ThemeSelector(
          currentThemeMode: currentThemeMode,
          onThemeModeChanged: onThemeModeChanged,
        ),
      ],
    );
  }
}
