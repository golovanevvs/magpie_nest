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
  String get dialogClose => 'Закрыть';

  @override
  String get dialogDone => 'Готово';

  @override
  String get dialogDelete => 'Удалить';

  @override
  String get buttonRestore => 'Восстановить';

  @override
  String get buttonCopy => 'Скопировать в буфер обмена';

  @override
  String get buttonFavorite => 'В избранное';

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
  String get defaultFolderName => 'Папка';

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

  @override
  String get defaultSnippetName => 'Сниппет';

  @override
  String get errorNameCannotBeEmpty => 'Имя не может быть пустым';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get fieldDescription => 'Описание';

  @override
  String get fieldDescriptionHint => 'Добавить описание...';

  @override
  String get buttonAddDescription => 'Добавить описание';

  @override
  String get buttonAddFragment => 'Добавить фрагмент';

  @override
  String defaultFragmentName(int number) {
    return 'Фрагмент $number';
  }

  @override
  String get fieldFragmentName => 'Имя фрагмента';

  @override
  String get fragmentNameBase => 'Фрагмент';

  @override
  String get buttonDeleteForever => 'Удалить навсегда';

  @override
  String get dialogDeleteForeverTitle => 'Удалить навсегда';

  @override
  String get dialogDeleteForeverMessage =>
      'Сниппет будет удалён безвозвратно. Это действие нельзя отменить.';

  @override
  String get buttonEmptyTrash => 'Очистить корзину';

  @override
  String get dialogEmptyTrashTitle => 'Очистить корзину';

  @override
  String get dialogEmptyTrashMessage =>
      'Все сниппеты из корзины будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get settingsCloud => 'Синхронизация';

  @override
  String get cloudStatusNotConfigured => 'Облачная синхронизация не настроена.';

  @override
  String cloudStatusConnected(String url) {
    return 'Подключено к $url.';
  }

  @override
  String get cloudProviderLabel => 'Провайдер';

  @override
  String get cloudProviderCustom => 'Свой вариант';

  @override
  String get cloudUrlLabel => 'Адрес сервера';

  @override
  String get cloudUsernameLabel => 'Имя пользователя (необязательно)';

  @override
  String get cloudPasswordLabel => 'Пароль (необязательно)';

  @override
  String get cloudNoAuthHint =>
      'Оставьте имя пользователя и пароль пустыми для подключения без аутентификации.';

  @override
  String get cloudTestConnection => 'Проверить соединение';

  @override
  String get cloudConnect => 'Подключить';

  @override
  String get cloudDisconnect => 'Отключить';

  @override
  String get cloudDisconnectDialogTitle => 'Отключение от облака';

  @override
  String get cloudDisconnectDialogBody =>
      'Выберите, что сделать с данными на сервере.';

  @override
  String get cloudDisconnectJust => 'Только отключить';

  @override
  String get cloudDisconnectAndDelete => 'Отключить и удалить облачную копию';

  @override
  String get cloudDeleteTitle => 'Удалить облачную копию?';

  @override
  String cloudDeleteBody(String folder, String url) {
    return 'Будет безвозвратно удалена общая папка синхронизации \"$folder\" на сервере $url. Другие устройства потеряют эту копию. Локальные данные на этом устройстве НЕ будут удалены.';
  }

  @override
  String get cloudDeleteConfirm => 'Удалить и отключить';

  @override
  String cloudPurgeFailed(String error) {
    return 'Не удалось удалить облачную копию: $error';
  }

  @override
  String get cloudConnectionOk => 'Соединение установлено.';

  @override
  String cloudConnectionFailed(String error) {
    return 'Ошибка соединения: $error';
  }

  @override
  String get cloudInvalidUrl => 'Введите корректный http(s)-адрес.';

  @override
  String get cloudSyncNow => 'Синхронизировать';

  @override
  String get cloudSyncing => 'Синхронизация…';

  @override
  String cloudLastSynced(String time) {
    return 'Последняя синхронизация: $time';
  }

  @override
  String cloudSyncFailed(String error) {
    return 'Ошибка синхронизации: $error';
  }

  @override
  String get cloudFolderLabel => 'Папка на сервере';

  @override
  String get cloudFolderHint =>
      'Батчи журнала сохраняются в эту папку. Используйте одинаковую папку на всех устройствах.';

  @override
  String get cloudFolderNameLabel => 'Имя папки';

  @override
  String get cloudParentFolderLabel => 'Расположение';

  @override
  String get cloudRootFolder => 'Корень облака';

  @override
  String get cloudParentFolderHint =>
      'Файлы журнала сохраняются в выбранном расположении под указанным именем папки.';

  @override
  String get cloudInvalidFolderName =>
      'Введите корректное имя папки (буквы, цифры, подчёркивание, точка, дефис; без пробелов и зарезервированных символов).';

  @override
  String get cloudBrowse => 'Обзор папок на сервере';

  @override
  String get cloudPickFolder => 'Выберите папку';

  @override
  String get cloudNewFolder => 'Новая папка';

  @override
  String get cloudNewFolderName => 'Имя папки';

  @override
  String get cloudCreate => 'Создать';

  @override
  String get cloudUseThisFolder => 'Выбрать эту папку';

  @override
  String get cloudNoSubfolders => 'Нет подпапок';

  @override
  String get cloudRetry => 'Повторить';

  @override
  String get statusCloudNotConfigured => 'Облако не подключено';

  @override
  String get statusCloudConnected => 'Подключено';

  @override
  String statusCloudSynced(String time) {
    return 'Синхронизировано в $time';
  }

  @override
  String get statusCloudSyncError => 'Ошибка синхронизации';
}
