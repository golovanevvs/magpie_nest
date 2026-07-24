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
}
