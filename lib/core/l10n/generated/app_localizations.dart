import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// The main title of the application shown in the app bar
  ///
  /// In en, this message translates to:
  /// **'Magpie Nest'**
  String get appTitle;

  /// Navigation rail label for the Library section
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Navigation rail label for the All Snippets section
  ///
  /// In en, this message translates to:
  /// **'All Snippets'**
  String get navAllSnippets;

  /// Navigation rail label for the Favorites section
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// Navigation rail label for the Trash section
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get navTrash;

  /// Sidebar label for the Inbox virtual folder
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get sidebarInbox;

  /// Sidebar title for the Favorites section
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get sidebarFavorites;

  /// Sidebar title for the Trash section
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get sidebarTrash;

  /// Placeholder text shown when no snippet is selected
  ///
  /// In en, this message translates to:
  /// **'Select a snippet to view'**
  String get viewerSelectSnippet;

  /// Placeholder text shown when the snippet list is empty
  ///
  /// In en, this message translates to:
  /// **'No snippets'**
  String get listNoSnippets;

  /// Title of the confirmation dialog when deleting a snippet
  ///
  /// In en, this message translates to:
  /// **'Delete Snippet'**
  String get dialogDeleteTitle;

  /// Message shown in the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this snippet? It will be moved to the Trash.'**
  String get dialogDeleteMessage;

  /// Label for the cancel button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// Label for the delete button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// Label for the restore button in the snippet viewer
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get buttonRestore;

  /// Tooltip for the copy button in the code viewer
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get buttonCopy;

  /// Message shown after copying code to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get snackbarCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
