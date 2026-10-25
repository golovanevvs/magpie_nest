import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_folder_browser.dart';
import 'package:magpie_nest/core/sync/webdav_transport.dart';
import 'package:magpie_nest/core/ui/adaptive_button.dart';
import 'package:magpie_nest/core/ui/adaptive_dialog.dart';

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
      builder: (context) => AdaptiveAlertDialog(
        title: Text(l10n.cloudNewFolder),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.cloudNewFolderName),
        ),
        actions: [
          AdaptiveDialogAction(
            label: l10n.dialogCancel,
            onPressed: () => Navigator.pop(context),
          ),
          AdaptiveFilledDialogAction(
            label: l10n.cloudCreate,
            onPressed: () => Navigator.pop(context, controller.text),
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
        return AdaptiveAlertDialog(
          title: Text(l10n.cloudPickFolder),
          content: SizedBox(width: 320, height: 360, child: _buildBody()),
          actions: [
            AdaptiveDialogAction(
              label: l10n.cloudNewFolder,
              onPressed: _createFolder,
            ),
            AdaptiveDialogAction(
              label: l10n.dialogCancel,
              onPressed: () => Navigator.pop(context),
            ),
            AdaptiveFilledDialogAction(
              label: l10n.cloudUseThisFolder,
              onPressed: () => Navigator.pop(context, _browser.path),
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
          AdaptiveOutlinedButton(
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
