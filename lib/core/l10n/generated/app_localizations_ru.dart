// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Magpie Nest';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navAllSnippets => 'Все сниппеты';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navTrash => 'Корзина';

  @override
  String get sidebarInbox => 'Входящие';

  @override
  String get sidebarFavorites => 'Избранное';

  @override
  String get sidebarTrash => 'Корзина';

  @override
  String get viewerSelectSnippet => 'Выберите сниппет для просмотра';

  @override
  String get listNoSnippets => 'Нет сниппетов';

  @override
  String get dialogDeleteTitle => 'Удалить сниппет';

  @override
  String get dialogDeleteMessage =>
      'Вы уверены, что хотите удалить этот сниппет? Он будет перемещён в корзину.';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogDelete => 'Удалить';

  @override
  String get buttonRestore => 'Восстановить';
}
