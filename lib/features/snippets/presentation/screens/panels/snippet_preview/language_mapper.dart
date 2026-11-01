import 'package:re_highlight/languages/bash.dart' as lang_bash;
import 'package:re_highlight/languages/c.dart' as lang_c;
import 'package:re_highlight/languages/cpp.dart' as lang_cpp;
import 'package:re_highlight/languages/csharp.dart' as lang_csharp;
import 'package:re_highlight/languages/css.dart' as lang_css;
import 'package:re_highlight/languages/dart.dart' as lang_dart;
import 'package:re_highlight/languages/go.dart' as lang_go;
import 'package:re_highlight/languages/java.dart' as lang_java;
import 'package:re_highlight/languages/javascript.dart' as lang_javascript;
import 'package:re_highlight/languages/json.dart' as lang_json;
import 'package:re_highlight/languages/kotlin.dart' as lang_kotlin;
import 'package:re_highlight/languages/markdown.dart' as lang_markdown;
import 'package:re_highlight/languages/php.dart' as lang_php;
import 'package:re_highlight/languages/plaintext.dart' as lang_plaintext;
import 'package:re_highlight/languages/powershell.dart' as lang_powershell;
import 'package:re_highlight/languages/python.dart' as lang_python;
import 'package:re_highlight/languages/ruby.dart' as lang_ruby;
import 'package:re_highlight/languages/rust.dart' as lang_rust;
import 'package:re_highlight/languages/scss.dart' as lang_scss;
import 'package:re_highlight/languages/sql.dart' as lang_sql;
import 'package:re_highlight/languages/swift.dart' as lang_swift;
import 'package:re_highlight/languages/typescript.dart' as lang_typescript;
import 'package:re_highlight/languages/xml.dart' as lang_xml;
import 'package:re_highlight/languages/yaml.dart' as lang_yaml;
import 'package:re_highlight/re_highlight.dart' show Mode;

/// Возвращает правило подсветки Re-Highlight ([Mode]) по названию языка
/// или `null`, если язык не поддерживается.
Mode? codeLanguageMode(String languageName) {
  final normalized = languageName.toLowerCase().trim();
  switch (normalized) {
    case 'dart':
      return lang_dart.langDart;
    case 'javascript':
    case 'js':
      return lang_javascript.langJavascript;
    case 'typescript':
    case 'ts':
      return lang_typescript.langTypescript;
    case 'python':
    case 'py':
      return lang_python.langPython;
    case 'java':
      return lang_java.langJava;
    case 'go':
    case 'golang':
      return lang_go.langGo;
    case 'c#':
    case 'csharp':
    case 'cs':
      return lang_csharp.langCsharp;
    case 'c++':
    case 'cpp':
      return lang_cpp.langCpp;
    case 'c':
      return lang_c.langC;
    case 'html':
    case 'xml':
      return lang_xml.langXml;
    case 'css':
      return lang_css.langCss;
    case 'scss':
      return lang_scss.langScss;
    case 'sql':
      return lang_sql.langSql;
    case 'json':
      return lang_json.langJson;
    case 'yaml':
    case 'yml':
      return lang_yaml.langYaml;
    case 'markdown':
    case 'md':
      return lang_markdown.langMarkdown;
    case 'bash':
    case 'shell':
    case 'sh':
      return lang_bash.langBash;
    case 'rust':
    case 'rs':
      return lang_rust.langRust;
    case 'kotlin':
    case 'kt':
      return lang_kotlin.langKotlin;
    case 'swift':
      return lang_swift.langSwift;
    case 'php':
      return lang_php.langPhp;
    case 'ruby':
    case 'rb':
      return lang_ruby.langRuby;
    case 'powershell':
    case 'ps1':
      return lang_powershell.langPowershell;
    case 'plaintext':
      return lang_plaintext.langPlaintext;
    default:
      return null;
  }
}
