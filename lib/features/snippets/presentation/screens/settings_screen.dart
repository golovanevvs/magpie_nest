import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/cloud_folder_picker_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final CloudConnectionController cloud;
  final SyncController sync;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.cloud,
    required this.sync,
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
    final menuItems = [
      (icon: Icons.language, title: l10n.settingsLanguage),
      (icon: Icons.dark_mode, title: l10n.settingsTheme),
      (icon: Icons.cloud, title: l10n.settingsCloud),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 220,
          child: ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                selected: _selectedMenuIndex == index,
                onTap: () => setState(() => _selectedMenuIndex = index),
              );
            },
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
      case 2:
        return _CloudPanel(cloud: widget.cloud, sync: widget.sync);
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.settingsLanguage),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.settingsTheme),
        const SizedBox(height: 8),
        _ThemeSelector(
          currentThemeMode: currentThemeMode,
          onThemeModeChanged: onThemeModeChanged,
        ),
      ],
    );
  }
}

class _CloudPanel extends StatefulWidget {
  final CloudConnectionController cloud;
  final SyncController sync;

  const _CloudPanel({required this.cloud, required this.sync});

  @override
  State<_CloudPanel> createState() => _CloudPanelState();
}

class _CloudPanelState extends State<_CloudPanel> {
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _folderController = TextEditingController(text: kDefaultJournalDir);

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  WebdavCredentials? _readForm() {
    final url = _urlController.text.trim();
    final uri = Uri.tryParse(url);
    final validUrl =
        url.isNotEmpty &&
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!validUrl) return null;

    final folder = _folderController.text;
    if (folder.contains('..')) return null;

    return WebdavCredentials(
      url: url,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      folder: normalizeJournalDir(folder),
    );
  }

  Future<void> _pickFolder() async {
    final credentials = _readForm();
    if (credentials == null) {
      _showSnackBar(AppLocalizations.of(context)!.cloudInvalidUrl);
      return;
    }
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => CloudFolderPickerDialog(
        transport: webdavTransportFrom(credentials),
        initialPath: _folderController.text,
      ),
    );
    if (picked != null) {
      setState(() => _folderController.text = picked);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<bool> Function(WebdavCredentials) action) async {
    final credentials = _readForm();
    if (credentials == null) {
      _showSnackBar(AppLocalizations.of(context)!.cloudInvalidUrl);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final ok = await action(credentials);
    if (!mounted) return;
    _showSnackBar(
      ok
          ? l10n.cloudConnectionOk
          : l10n.cloudConnectionFailed(widget.cloud.error ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([widget.cloud, widget.sync]),
      builder: (context, _) {
        final cloud = widget.cloud;
        final connected = cloud.isConnected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: l10n.settingsCloud),
            const SizedBox(height: 8),

            Text(
              connected
                  ? l10n.cloudStatusConnected(cloud.connectedUrl ?? '')
                  : l10n.cloudStatusNotConfigured,
            ),
            if (connected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${l10n.cloudFolderLabel}: ${cloud.connectedFolder ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),

            if (connected)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton(
                    onPressed: cloud.busy ? null : cloud.disconnect,
                    child: Text(l10n.cloudDisconnect),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: widget.sync.syncing ? null : widget.sync.syncNow,
                    icon: widget.sync.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(l10n.cloudSyncNow),
                  ),
                  if (widget.sync.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.cloudSyncFailed(widget.sync.error!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (widget.sync.lastSyncedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.cloudLastSynced(
                          DateFormat.Hm().format(widget.sync.lastSyncedAt!),
                        ),
                      ),
                    ),
                ],
              )
            else ...[
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.cloudUrlLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.cloudUsernameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.cloudPasswordLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _folderController,
                decoration: InputDecoration(
                  labelText: l10n.cloudFolderLabel,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: l10n.cloudBrowse,
                    onPressed: _pickFolder,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.cloudFolderHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.cloudNoAuthHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: cloud.busy
                        ? null
                        : () => _run(cloud.testConnection),
                    child: Text(l10n.cloudTestConnection),
                  ),
                  FilledButton(
                    onPressed: cloud.busy ? null : () => _run(cloud.connect),
                    child: Text(l10n.cloudConnect),
                  ),
                ],
              ),

              if (cloud.busy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: SizedBox(height: 2, child: LinearProgressIndicator()),
                ),
            ],
          ],
        );
      },
    );
  }
}
