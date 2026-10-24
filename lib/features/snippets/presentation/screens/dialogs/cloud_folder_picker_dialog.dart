import 'package:flutter/material.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_folder_browser.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';

class CloudFolderPickerDialog extends StatefulWidget {
  final WebdavTransport transport;
  final String initialPath;

  const CloudFolderPickerDialog({
    super.key,
    required this.transport,
    required this.initialPath,
  });

  @override
  State<CloudFolderPickerDialog> createState() =>
      _CloudFolderPickerDialogState();
}

class _CloudFolderPickerDialogState extends State<CloudFolderPickerDialog> {
  late final CloudFolderBrowser _browser;

  @override
  void initState() {
    super.initState();
    _browser = CloudFolderBrowser(
      transport: widget.transport,
      initialPath: widget.initialPath,
    );
    _browser.reload();
  }

  @override
  void dispose() {
    _browser.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloudNewFolder),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.cloudNewFolderName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.cloudCreate),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      await _browser.createFolder(name);
    } on ArgumentError {
      // Invalid name — the input dialog can simply be opened again.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _browser,
      builder: (context, _) {
        return AlertDialog(
          title: Text(l10n.cloudPickFolder),
          content: SizedBox(width: 320, height: 360, child: _buildBody()),
          actions: [
            TextButton(
              onPressed: _createFolder,
              child: Text(l10n.cloudNewFolder),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _browser.path),
              child: Text(l10n.cloudUseThisFolder),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_browser.busy) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_browser.error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.cloudConnectionFailed(_browser.error!)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _browser.reload,
            child: Text(l10n.cloudRetry),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _browser.atRoot ? '/' : '/${_browser.path}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _browser.folders.isEmpty
              ? Center(child: Text(l10n.cloudNoSubfolders))
              : ListView(
                  children: [
                    if (!_browser.atRoot)
                      ListTile(
                        leading: const Icon(Icons.arrow_upward),
                        title: const Text('..'),
                        dense: true,
                        onTap: _browser.up,
                      ),
                    for (final name in _browser.folders)
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(name),
                        dense: true,
                        onTap: () => _browser.enter(name),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
