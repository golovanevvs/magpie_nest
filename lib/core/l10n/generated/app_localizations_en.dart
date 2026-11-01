// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Magpie Nest';

  @override
  String get navLibrary => 'Library';

  @override
  String get navAllSnippets => 'All Snippets';

  @override
  String get navSettings => 'Settings';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navTrash => 'Trash';

  @override
  String get sidebarInbox => 'Inbox';

  @override
  String get sidebarFavorites => 'Favorites';

  @override
  String get sidebarTrash => 'Trash';

  @override
  String get sidebarSearchHint => 'Search folders';

  @override
  String get sidebarNoFolders => 'No folders found';

  @override
  String get sidebarLibrary => 'Library';

  @override
  String get sidebarFolders => 'Folders';

  @override
  String get viewerSelectSnippet => 'Select a snippet to view';

  @override
  String get listNoSnippets => 'No snippets';

  @override
  String get dialogDeleteTitle => 'Delete Snippet';

  @override
  String get dialogDeleteMessage =>
      'Are you sure you want to delete this snippet? It will be moved to the Trash.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogClose => 'Close';

  @override
  String get dialogDone => 'Done';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get buttonRestore => 'Restore';

  @override
  String get buttonCopy => 'Copy to clipboard';

  @override
  String get buttonFavorite => 'Toggle favorite';

  @override
  String get snackbarCopied => 'Copied to clipboard';

  @override
  String get dialogCreateSnippetTitle => 'Create New Snippet';

  @override
  String get fieldSnippetName => 'Snippet Name';

  @override
  String get fieldLanguage => 'Language';

  @override
  String get fieldContent => 'Content';

  @override
  String get dialogCreate => 'Create';

  @override
  String get errorNameRequired => 'Snippet name is required';

  @override
  String get buttonNewSnippet => 'New Snippet';

  @override
  String get defaultFolderName => 'Folder';

  @override
  String get buttonNewFolder => 'New Folder';

  @override
  String get buttonRename => 'Rename';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get dialogDeleteFolderTitle => 'Delete Folder';

  @override
  String get dialogDeleteFolderMessage =>
      'Are you sure you want to delete this folder? All snippets inside will be moved to the Trash.';

  @override
  String get contextMenuNewFolder => 'New Folder';

  @override
  String get contextMenuRename => 'Rename';

  @override
  String get contextMenuSetIcon => 'Set Icon';

  @override
  String get contextMenuDefaultLanguage => 'Default Language';

  @override
  String get defaultSnippetName => 'Snippet';

  @override
  String get errorNameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldDescriptionHint => 'Add a description...';

  @override
  String get buttonAddDescription => 'Add description';

  @override
  String get buttonAddFragment => 'Add fragment';

  @override
  String defaultFragmentName(int number) {
    return 'Fragment $number';
  }

  @override
  String get fieldFragmentName => 'Fragment name';

  @override
  String get fragmentNameBase => 'Fragment';

  @override
  String get buttonDeleteForever => 'Delete forever';

  @override
  String get dialogDeleteForeverTitle => 'Delete forever';

  @override
  String get dialogDeleteForeverMessage =>
      'This snippet will be permanently deleted. This action cannot be undone.';

  @override
  String get buttonEmptyTrash => 'Empty Trash';

  @override
  String get dialogEmptyTrashTitle => 'Empty Trash';

  @override
  String get dialogEmptyTrashMessage =>
      'All snippets in the Trash will be permanently deleted. This action cannot be undone.';

  @override
  String get settingsCloud => 'Sync';

  @override
  String get cloudStatusNotConfigured => 'Cloud sync is not configured.';

  @override
  String cloudStatusConnected(String url) {
    return 'Connected to $url.';
  }

  @override
  String get cloudProviderLabel => 'Provider';

  @override
  String get cloudProviderCustom => 'Custom (manual)';

  @override
  String get cloudUrlLabel => 'Server URL';

  @override
  String get cloudUsernameLabel => 'Username (optional)';

  @override
  String get cloudPasswordLabel => 'Password (optional)';

  @override
  String get cloudNoAuthHint =>
      'Leave username and password empty to connect without authentication.';

  @override
  String get cloudTestConnection => 'Test connection';

  @override
  String get cloudConnect => 'Connect';

  @override
  String get cloudDisconnect => 'Disconnect';

  @override
  String get cloudDisconnectDialogTitle => 'Disconnect from cloud';

  @override
  String get cloudDisconnectDialogBody =>
      'Choose what to do with your data on the server.';

  @override
  String get cloudDisconnectJust => 'Just disconnect';

  @override
  String get cloudDisconnectAndDelete => 'Disconnect & delete cloud copy';

  @override
  String get cloudDeleteTitle => 'Delete cloud copy?';

  @override
  String cloudDeleteBody(String folder, String url) {
    return 'This permanently deletes the shared sync folder \"$folder\" on $url. Other devices lose this copy. Local data on this device is NOT deleted.';
  }

  @override
  String get cloudDeleteConfirm => 'Delete & disconnect';

  @override
  String cloudPurgeFailed(String error) {
    return 'Could not delete the cloud copy: $error';
  }

  @override
  String get cloudConnectionOk => 'Connection successful.';

  @override
  String cloudConnectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get cloudInvalidUrl => 'Enter a valid http(s) URL.';

  @override
  String get cloudSyncNow => 'Sync now';

  @override
  String get cloudSyncing => 'Syncing…';

  @override
  String cloudLastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String cloudSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get cloudFolderLabel => 'Folder on server';

  @override
  String get cloudFolderHint =>
      'Journal batches are stored in this folder. Use the same folder on all your devices.';

  @override
  String get cloudFolderNameLabel => 'Folder name';

  @override
  String get cloudParentFolderLabel => 'Location';

  @override
  String get cloudRootFolder => 'Cloud root';

  @override
  String get cloudParentFolderHint =>
      'Journal files are stored in the selected location under the folder name.';

  @override
  String get cloudInvalidFolderName =>
      'Enter a valid folder name (letters, digits, underscore, dot, dash; no spaces or reserved symbols).';

  @override
  String get cloudBrowse => 'Browse server folders';

  @override
  String get cloudPickFolder => 'Choose a folder';

  @override
  String get cloudNewFolder => 'New folder';

  @override
  String get cloudNewFolderName => 'Folder name';

  @override
  String get cloudCreate => 'Create';

  @override
  String get cloudUseThisFolder => 'Use this folder';

  @override
  String get cloudNoSubfolders => 'No subfolders';

  @override
  String get cloudRetry => 'Retry';

  @override
  String get statusCloudNotConfigured => 'Cloud not connected';

  @override
  String get statusCloudConnected => 'Connected';

  @override
  String statusCloudSynced(String time) {
    return 'Synced at $time';
  }

  @override
  String get statusCloudSyncError => 'Sync error';
}
