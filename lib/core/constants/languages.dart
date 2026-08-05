class SupportedLanguages {
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

  static List<Map<String, String>> get allWithNames {
    final list = all.map((code) {
      return {'code': code, 'name': _getDisplayNames()[code] ?? code};
    }).toList();

    list.sort((a, b) => a['name']!.compareTo(b['name']!));
    return list;
  }

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
