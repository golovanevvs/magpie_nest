import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';

class StatusBar extends StatelessWidget {
  final CloudConnectionController cloud;
  final SyncController sync;
  final VoidCallback onCloudStatusTap;
  final VoidCallback onSettingsTap;

  const StatusBar({
    super.key,
    required this.cloud,
    required this.sync,
    required this.onCloudStatusTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: ListenableBuilder(
        listenable: Listenable.merge([cloud, sync]),
        builder: (context, _) {
          return Row(
            children: [
              Expanded(child: _buildCloudStatus(context)),
              _buildSyncButton(context),
              _buildSettingsButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCloudStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    Color color;
    String text;
    String? tooltip;

    if (!cloud.isConnected) {
      icon = Icons.cloud_off;
      color = colorScheme.onSurfaceVariant;
      text = l10n.statusCloudNotConfigured;
    } else if (sync.syncing) {
      icon = Icons.sync;
      color = colorScheme.primary;
      text = l10n.cloudSyncing;
    } else if (sync.error != null) {
      icon = Icons.sync_problem;
      color = colorScheme.error;
      text = l10n.statusCloudSyncError;
      tooltip = sync.error;
    } else if (sync.lastSyncedAt != null) {
      icon = Icons.cloud_done;
      color = colorScheme.primary;
      text = l10n.statusCloudSynced(
        DateFormat('HH:mm').format(sync.lastSyncedAt!),
      );
    } else {
      icon = Icons.cloud_done;
      color = colorScheme.primary;
      text = l10n.statusCloudConnected;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: tooltip ?? text,
        child: InkWell(
          onTap: onCloudStatusTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: sync.canSync ? () => sync.syncNow() : null,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: Theme.of(context).textTheme.bodySmall,
      ),
      icon: sync.syncing
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync, size: 16),
      label: Text(l10n.cloudSyncNow),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.settings, size: 18),
      tooltip: l10n.navSettings,
      onPressed: onSettingsTap,
      visualDensity: VisualDensity.compact,
    );
  }
}