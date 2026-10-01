import 'package:highlight/languages/bash.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/cs.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/ruby.dart';
import 'package:highlight/languages/rust.dart';
import 'package:highlight/languages/scss.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/swift.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';

/// Возвращает объект языка для подсветки синтаксиса по его названию
/// или `null`, если язык не поддерживается.
dynamic mapLanguage(String languageName) {
  final normalized = languageName.toLowerCase().trim();
  switch (normalized) {
    case 'dart':
      return dart;
    case 'javascript':
    case 'js':
      return javascript;
    case 'typescript':
    case 'ts':
      return typescript;
    case 'python':
    case 'py':
      return python;
    case 'java':
      return java;
    case 'go':
    case 'golang':
      return go;
    case 'c#':
    case 'csharp':
    case 'cs':
      return cs;
    case 'c++':
    case 'cpp':
    case 'c':
      return cpp;
    case 'html':
    case 'xml':
      return xml;
    case 'css':
      return css;
    case 'scss':
      return scss;
    case 'sql':
      return sql;
    case 'json':
      return json;
    case 'yaml':
    case 'yml':
      return yaml;
    case 'markdown':
    case 'md':
      return markdown;
    case 'bash':
    case 'shell':
    case 'sh':
      return bash;
    case 'rust':
    case 'rs':
      return rust;
    case 'kotlin':
    case 'kt':
      return kotlin;
    case 'swift':
      return swift;
    case 'php':
      return php;
    case 'ruby':
    case 'rb':
      return ruby;
    case 'powershell':
    case 'ps1':
      return powershell;
    default:
      return null;
  }
}
