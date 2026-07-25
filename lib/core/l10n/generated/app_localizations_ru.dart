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
  String get navSnippets => 'Сниппеты';

  @override
  String get navSettings => 'Настройки';

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
  String get sidebarSearchHint => 'Поиск папок';

  @override
  String get sidebarNoFolders => 'Папки не найдены';

  @override
  String get sidebarLibrary => 'Библиотека';

  @override
  String get sidebarFolders => 'Папки';

  @override
  String get sidebarTags => 'Теги';

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

  @override
  String get buttonCopy => 'Скопировать в буфер обмена';

  @override
  String get snackbarCopied => 'Скопировано в буфер обмена';

  @override
  String get dialogCreateSnippetTitle => 'Создать новый сниппет';

  @override
  String get fieldSnippetName => 'Название сниппета';

  @override
  String get fieldLanguage => 'Язык';

  @override
  String get fieldContent => 'Содержимое';

  @override
  String get dialogCreate => 'Создать';

  @override
  String get errorNameRequired => 'Название сниппета обязательно';

  @override
  String get buttonNewSnippet => 'Новый сниппет';

  @override
  String get untitledFolder => 'Новая папка';

  @override
  String get buttonNewFolder => 'Новая папка';

  @override
  String get buttonRename => 'Переименовать';

  @override
  String get buttonDelete => 'Удалить';

  @override
  String get dialogDeleteFolderTitle => 'Удалить папку';

  @override
  String get dialogDeleteFolderMessage =>
      'Вы уверены, что хотите удалить эту папку? Все сниппеты внутри будут перемещены в Корзину.';

  @override
  String get contextMenuNewFolder => 'Новая папка';

  @override
  String get contextMenuRename => 'Переименовать';

  @override
  String get contextMenuSetIcon => 'Установить иконку';

  @override
  String get contextMenuDefaultLanguage => 'Язык по умолчанию';
}
