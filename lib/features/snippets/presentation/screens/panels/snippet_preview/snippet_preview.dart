import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

// Импортируем только переменные языков, класс Language нам не нужен
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

import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/delete_confirmation_dialog.dart';

/// Snippet preview panel (Panel 4).
///
/// Displays the selected snippet's name, language, tags, and content
/// with syntax highlighting and inline editing.
class SnippetPreview extends StatefulWidget {
  final int selectedIndex;
  final AppController controller;

  const SnippetPreview({
    super.key,
    required this.selectedIndex,
    required this.controller,
  });

  @override
  State<SnippetPreview> createState() => _SnippetPreviewState();
}

class _SnippetPreviewState extends State<SnippetPreview> {
  late final TextEditingController _nameController;
  late CodeController _codeController;
  String _lastValidName = '';
  bool _nameIsEmpty = false;
  String? _lastSnippetId; // ← НОВОЕ: храним предыдущий ID

  @override
  void initState() {
    super.initState();
    final snippet = widget.controller.selectedSnippet;
    final name = snippet?.name ?? '';
    _nameController = TextEditingController(text: name);
    _lastValidName = name;
    _lastSnippetId = snippet?.id; // ← НОВОЕ

    _codeController = CodeController(
      text: snippet?.fragments.isNotEmpty == true
          ? snippet!.fragments.first.content
          : '',
      language: _mapLanguage(
        snippet?.fragments.isNotEmpty == true
            ? snippet!.fragments.first.language
            : '',
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SnippetPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final snippet = widget.controller.selectedSnippet;
    if (snippet == null) return;

    // Если сменился сниппет — пересоздаём контроллер кода
    if (_lastSnippetId != snippet.id) {
      // ← ИСПРАВЛЕНО: сравниваем с сохранённым ID

      _codeController.dispose();

      final content = snippet.fragments.isNotEmpty
          ? snippet.fragments.first.content
          : '';
      final language = snippet.fragments.isNotEmpty
          ? snippet.fragments.first.language
          : '';

      final mappedLanguage = _mapLanguage(language);

      _codeController = CodeController(text: content, language: mappedLanguage);

      _lastSnippetId = snippet.id; // ← НОВОЕ: обновляем сохранённый ID
    }

    if (_lastSnippetId != snippet.id || _nameController.text != snippet.name) {
      _nameController.text = snippet.name;
      _lastValidName = snippet.name;
      _nameIsEmpty = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value, AppLocalizations l10n) {
    final controller = widget.controller;
    final snippet = controller.selectedSnippet;
    if (snippet == null) return;

    if (value.isEmpty) {
      setState(() {
        _nameIsEmpty = true;
      });
      _nameController.text = _lastValidName;
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _lastValidName.length),
      );
      return;
    }

    if (_nameIsEmpty) {
      setState(() {
        _nameIsEmpty = false;
      });
    }

    _lastValidName = value;
    controller.updateSnippetName(snippet.id, value);
  }

  dynamic _mapLanguage(String languageName) {
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

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final snippet = controller.selectedSnippet;
    final l10n = AppLocalizations.of(context)!;

    if (snippet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.viewerSelectSnippet),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: l10n.fieldSnippetName,
                    errorText: _nameIsEmpty
                        ? l10n.errorNameCannotBeEmpty
                        : null,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  onChanged: (value) => _onNameChanged(value, l10n),
                ),
              ),
              if (widget.selectedIndex == 3)
                IconButton(
                  icon: const Icon(Icons.restore_from_trash),
                  tooltip: l10n.buttonRestore,
                  onPressed: () => controller.restoreSnippet(snippet.id),
                ),
              IconButton(
                icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => controller.toggleFavorite(snippet.id),
              ),
              if (widget.selectedIndex != 3)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDeleteSnippet(context, snippet),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(snippet.activeFragment.language)),
              ...snippet.tags.map((tag) => Chip(label: Text(tag))),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildCodeViewer(context, snippet)),
        ],
      ),
    );
  }

  Widget _buildCodeViewer(BuildContext context, Snippet snippet) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF282C34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21252B),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  snippet.activeFragment.language,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                  tooltip: l10n.buttonCopy,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: _codeController.text),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.snackbarCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: atomOneDarkTheme),
              child: CodeField(
                controller: _codeController,
                gutterStyle: const GutterStyle(
                  showLineNumbers: true,
                  width: 60,
                ),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSnippet(
    BuildContext context,
    Snippet snippet,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (shouldDelete == true) {
      widget.controller.deleteSnippet(snippet.id);
    }
  }
}
