const kDefaultJournalDir = 'magpie_nest/';

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
