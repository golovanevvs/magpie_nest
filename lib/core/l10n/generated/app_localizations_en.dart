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
  String get dialogDelete => 'Delete';

  @override
  String get buttonRestore => 'Restore';

  @override
  String get buttonCopy => 'Copy to clipboard';

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
  String get untitledFolder => 'Untitled Folder';

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
      'Are you sure you want to delete this folder? All snippets inside will be moved to Inbox.';
}
