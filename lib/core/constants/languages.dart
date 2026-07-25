/// List of programming languages supported by the application.
///
/// This list is used in dropdown menus for language selection.
/// Each language code corresponds to a highlight.js language identifier.
class SupportedLanguages {
  /// Returns a list of all supported language codes.
  static const List<String> all = [
    'dart',
    'javascript',
    'typescript',
    'python',
    'java',
    'kotlin',
    'swift',
    'go',
    'rust',
    'c',
    'cpp',
    'csharp',
    'ruby',
    'php',
    'bash',
    'powershell',
    'sql',
    'html',
    'css',
    'scss',
    'json',
    'yaml',
    'xml',
    'markdown',
    'plaintext',
  ];

  /// Returns a list of all supported languages with display names.
  ///
  /// The display names are in English. For localization, use [getDisplayName].
  static List<Map<String, String>> get allWithNames {
    final list = all.map((code) {
      return {'code': code, 'name': _getDisplayNames()[code] ?? code};
    }).toList();

    list.sort((a, b) => a['name']!.compareTo(b['name']!));
    return list;
  }

  /// Returns the display name for a language code.
  ///
  /// Falls back to the language code itself if no display name is found.
  static String getDisplayName(String code) {
    return _getDisplayNames()[code] ?? code;
  }

  static Map<String, String> _getDisplayNames() {
    return {
      'dart': 'Dart',
      'javascript': 'JavaScript',
      'typescript': 'TypeScript',
      'python': 'Python',
      'java': 'Java',
      'kotlin': 'Kotlin',
      'swift': 'Swift',
      'go': 'Go',
      'rust': 'Rust',
      'c': 'C',
      'cpp': 'C++',
      'csharp': 'C#',
      'ruby': 'Ruby',
      'php': 'PHP',
      'bash': 'Bash',
      'powershell': 'PowerShell',
      'sql': 'SQL',
      'html': 'HTML',
      'css': 'CSS',
      'scss': 'SCSS',
      'json': 'JSON',
      'yaml': 'YAML',
      'xml': 'XML',
      'markdown': 'Markdown',
      'plaintext': 'Plain Text',
    };
  }
}
