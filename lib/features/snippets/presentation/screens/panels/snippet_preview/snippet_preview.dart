import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
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
import 'package:magpie_nest/core/constants/languages.dart';

import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/utils/debouncer.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/delete_confirmation_dialog.dart';

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
  late final TextEditingController _descriptionController;
  late final FocusNode _nameFocusNode;
  late final Debouncer _descriptionDebouncer;
  late final Debouncer _contentDebouncer;
  late CodeController _codeController;

  bool _nameIsEmpty = false;
  String? _syncedSnippetId;
  String? _syncedFragmentId;
  String? _syncedFragmentLanguage;
  bool _isAddingDescription = false;
  bool _isSyncingCode = false;

  @override
  void initState() {
    super.initState();
    _descriptionDebouncer = Debouncer();
    _contentDebouncer = Debouncer();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _nameFocusNode = FocusNode()..addListener(_onNameFocusLost);

    widget.controller.addListener(_onControllerChanged);

    final snippet = widget.controller.selectedSnippet;

    _codeController = CodeController(text: '');

    if (snippet != null) {
      _syncSnippetState(snippet);
    } else {
      _codeController.addListener(_onCodeChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _nameFocusNode.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _descriptionDebouncer.dispose();
    _contentDebouncer.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final snippet = widget.controller.selectedSnippet;

    if (snippet == null) {
      if (_syncedSnippetId != null) {
        setState(() {
          _syncedSnippetId = null;
          _syncedFragmentId = null;
          _isAddingDescription = false;
        });
      }
      return;
    }

    final activeFragmentId = snippet.activeFragment.id;
    final snippetChanged = snippet.id != _syncedSnippetId;
    final fragmentChanged = activeFragmentId != _syncedFragmentId;
    final languageChanged =
        snippet.activeFragment.language != _syncedFragmentLanguage;

    if (snippetChanged || fragmentChanged || languageChanged) {
      setState(() {
        if (snippetChanged) {
          _syncSnippetState(snippet);
        } else if (fragmentChanged || languageChanged) {
          _syncCodeController(snippet);
          _syncedFragmentId = activeFragmentId;
          _syncedFragmentLanguage = snippet.activeFragment.language;
        }
      });
    }
  }

  void _syncCodeController(Snippet snippet) {
    final activeFragment = snippet.activeFragment;

    _isSyncingCode = true;
    _syncedFragmentLanguage = snippet.activeFragment.language;
    _codeController.dispose();
    _codeController = CodeController(
      text: activeFragment.content,
      language: _mapLanguage(activeFragment.language),
    );
    _codeController.addListener(_onCodeChanged);
    _isSyncingCode = false;
  }

  void _onCodeChanged() {
    // Игнорируем программные изменения (при синхронизации)
    if (_isSyncingCode) return;

    final snippet = widget.controller.selectedSnippet;
    if (snippet == null) return;

    final activeFragment = snippet.activeFragment;
    final content = _codeController.text;

    _contentDebouncer(() async {
      await widget.controller.updateFragmentContent(
        snippet.id,
        activeFragment.id,
        content,
      );
    });
  }

  void _syncSnippetState(Snippet snippet) {
    _nameController.text = snippet.name;
    _nameIsEmpty = false;

    _descriptionController.text = snippet.description ?? '';
    _isAddingDescription = false;

    _syncedSnippetId = snippet.id;
    _syncedFragmentId = snippet.activeFragment.id;
    _syncedFragmentLanguage = snippet.activeFragment.language;

    _isSyncingCode = true;
    _codeController.dispose();
    _codeController = CodeController(
      text: snippet.activeFragment.content,
      language: _mapLanguage(snippet.activeFragment.language),
    );
    _codeController.addListener(_onCodeChanged);
    _isSyncingCode = false;
  }

  void _onNameChanged(String value) {
    setState(() {
      _nameIsEmpty = value.trim().isEmpty;
    });
  }

  void _onNameFocusLost() {
    final snippet = widget.controller.selectedSnippet;
    if (snippet != null && !_nameFocusNode.hasFocus) {
      _commitSnippetName(snippet);
    }
  }

  void _commitSnippetName(Snippet snippet) {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      setState(() {
        _nameIsEmpty = true;
        _nameController.text = snippet.name;
      });
      return;
    }

    setState(() {
      _nameIsEmpty = false;
    });

    if (newName == snippet.name) return;

    widget.controller.updateSnippetName(snippet.id, newName);
  }

  void _onDescriptionChanged(String value) {
    final snippet = widget.controller.selectedSnippet;
    if (snippet == null) return;

    _descriptionDebouncer(() async {
      await widget.controller.updateSnippetDescription(snippet.id, value);

      if (value.trim().isEmpty && mounted) {
        setState(() {
          _isAddingDescription = false;
        });
      }
    });
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

  double _gutterWidthFor(int lineCount) {
    const issueFoldingColumns = 32.0;
    const margin = 10.0;
    const digitWidth = 8.4;
    const padding = 6.0;
    final digits = lineCount.toString().length;
    return issueFoldingColumns + margin + padding + digits * digitWidth;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snippet = widget.controller.selectedSnippet;

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

    final hasDescription =
        snippet.description != null && snippet.description!.isNotEmpty;
    final showDescriptionField = _isAddingDescription || hasDescription;
    final showAddDescriptionButton = !_isAddingDescription && !hasDescription;

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
                  focusNode: _nameFocusNode,
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
                  onChanged: _onNameChanged,
                  onSubmitted: (_) {
                    final snippet = widget.controller.selectedSnippet;
                    if (snippet != null) _commitSnippetName(snippet);
                  },
                ),
              ),
              if (widget.selectedIndex == 3)
                IconButton(
                  icon: const Icon(Icons.restore_from_trash),
                  tooltip: l10n.buttonRestore,
                  onPressed: () => widget.controller.restoreSnippet(snippet.id),
                ),
              // Add Description Button
              if (showAddDescriptionButton)
                IconButton(
                  icon: const Icon(Icons.notes),
                  tooltip: l10n.buttonAddDescription,
                  onPressed: () {
                    setState(() {
                      _isAddingDescription = true;
                    });
                  },
                ),
              // Add Fragment Button
              IconButton(
                icon: Icon(Icons.note_add_outlined),
                tooltip: l10n.buttonAddFragment,
                onPressed: () {
                  widget.controller.addFragment(
                    snippet.id,
                    l10n.fragmentNameBase,
                  );
                },
              ),
              // Favorite Button
              IconButton(
                icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => widget.controller.toggleFavorite(snippet.id),
              ),
              if (widget.selectedIndex != 3)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDeleteSnippet(context, snippet),
                ),
            ],
          ),
          if (showDescriptionField) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: l10n.fieldDescriptionHint,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: _onDescriptionChanged,
            ),
          ],
          const SizedBox(height: 8),
          DropdownButton(
            value: snippet.activeFragment.language,
            isDense: true,
            items: SupportedLanguages.allWithNames
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang['code'],
                    child: Text(lang['name']!),
                  ),
                )
                .toList(),
            onChanged: (language) {
              if (language == null) return;
              widget.controller.updateFragmentLanguage(
                snippet.id,
                snippet.activeFragment.id,
                language,
              );
            },
          ),
          const SizedBox(height: 16),
          _buildFragmentTabs(context, snippet),
          Expanded(child: _buildCodeViewer(context, snippet)),
        ],
      ),
    );
  }

  Widget _buildCodeViewer(BuildContext context, Snippet snippet) {
    final l10n = AppLocalizations.of(context)!;
    final lineCount = _codeController.text.split('\n').length;
    final gutterWidth = _gutterWidthFor(lineCount);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styles = isDark ? atomOneDarkTheme : atomOneLightTheme;
    final editorBackground = isDark
        ? const Color(0xFF282C34)
        : const Color(0xFFFAFAFA);
    final headerBackground = isDark
        ? const Color(0xFF21252B)
        : const Color(0xFFEDEDED);
    final headerForeground = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: editorBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: headerBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  snippet.activeFragment.language,
                  style: TextStyle(color: headerForeground, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.copy, color: headerForeground, size: 18),
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
              data: CodeThemeData(styles: styles),
              child: CodeField(
                controller: _codeController,
                gutterStyle: GutterStyle(
                  showLineNumbers: true,
                  width: gutterWidth,
                ),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
                expands: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFragmentTabs(BuildContext context, Snippet snippet) {
    if (snippet.fragments.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ...snippet.fragments.map(
            (fragment) => _FragmentTab(
              snippet: snippet,
              fragment: fragment,
              isActive: snippet.activeFragment.id == fragment.id,
              onTap: () =>
                  widget.controller.setActiveFragment(snippet.id, fragment.id),
              onRename: (newName) => widget.controller.updateFragmentName(
                snippet.id,
                fragment.id,
                newName,
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

class _FragmentTab extends StatefulWidget {
  final Snippet snippet;
  final Fragment fragment;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;

  const _FragmentTab({
    required this.snippet,
    required this.fragment,
    required this.isActive,
    required this.onTap,
    required this.onRename,
  });

  @override
  State<_FragmentTab> createState() => _FragmentTabState();
}

class _FragmentTabState extends State<_FragmentTab> {
  late final TextEditingController _nameController;
  late final FocusNode _focusNode;
  bool _isEditing = false;
  String _originalName = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fragment.name);
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _cancelRename();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
    _focusNode.addListener(_onFocusLost);
  }

  @override
  void didUpdateWidget(covariant _FragmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fragment.name != widget.fragment.name) {
      _nameController.text = widget.fragment.name;
      _originalName = widget.fragment.name;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusLost);
    _focusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onFocusLost() {
    if (!_focusNode.hasFocus && _isEditing) {
      _commitRename();
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _originalName = widget.fragment.name;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        _nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _nameController.text.length,
        );
      }
    });
  }

  void _commitRename() {
    final newName = _nameController.text.trim();
    setState(() {
      _isEditing = false;
    });

    if (newName.isEmpty || newName == widget.fragment.name) {
      _nameController.text = widget.fragment.name;
      return;
    }

    widget.onRename(newName);
  }

  void _cancelRename() {
    setState(() {
      _isEditing = false;
      _nameController.text = _originalName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isEditing ? null : widget.onTap,
        onDoubleTap: _isEditing ? null : _startEditing,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: _isEditing
              ? SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: l10n.fieldFragmentName,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    style: theme.textTheme.bodySmall,
                    onSubmitted: (_) => _commitRename(),
                  ),
                )
              : Text(
                  widget.fragment.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.isActive
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}
