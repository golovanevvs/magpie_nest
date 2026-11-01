const kDefaultSyncFolderName = 'magpie_nest';
const kDefaultJournalDir = '$kDefaultSyncFolderName/';

final _folderNamePattern = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9._-]*[A-Za-z0-9_-])?$');

String normalizeParent(String raw) {
  var s = raw.trim();
  while (s.startsWith('/')) {
    s = s.substring(1);
  }
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

bool isValidFolderName(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return false;
  if (s == '.' || s == '..' || s.contains('..')) return false;
  return _folderNamePattern.hasMatch(s);
}

String joinJournalDir(String parent, String name) {
  final p = normalizeParent(parent);
  final n = name.trim();
  return p.isEmpty ? '$n/' : '$p/$n/';
}

String normalizeJournalDir(String raw, {String fallback = kDefaultJournalDir}) {
  var s = raw.trim();
  while (s.startsWith('/')) {
    s = s.substring(1);
  }
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  if (s.isEmpty) return fallback;
  return '$s/';
}

class WebdavCredentials {
  final String url;
  final String username;
  final String password;
  final String folder;

  const WebdavCredentials({
    required this.url,
    required this.username,
    required this.password,
    this.folder = kDefaultJournalDir,
  });

  bool get isConfigured => url.trim().isNotEmpty;
  bool get isNoAuth => username.isEmpty && password.isEmpty;
}
