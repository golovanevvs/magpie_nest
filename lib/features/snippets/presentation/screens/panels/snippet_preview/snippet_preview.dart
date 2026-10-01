import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:magpie_nest/core/constants/languages.dart';

import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/utils/debouncer.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/code_viewer.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/fragment_tabs.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/language_mapper.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/snippet_header.dart';

class SnippetPreview extends StatefulWidget {
  final AppController controller;

  const SnippetPreview({super.key, required this.controller});

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
      language: mapLanguage(activeFragment.language),
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
      language: mapLanguage(snippet.activeFragment.language),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnippetHeader(
            controller: widget.controller,
            snippet: snippet,
            nameController: _nameController,
            nameFocusNode: _nameFocusNode,
            nameIsEmpty: _nameIsEmpty,
            isAddingDescription: _isAddingDescription,
            descriptionController: _descriptionController,
            onNameChanged: _onNameChanged,
            onCommitName: () {
              final selected = widget.controller.selectedSnippet;
              if (selected != null) _commitSnippetName(selected);
            },
            onAddDescription: () {
              setState(() {
                _isAddingDescription = true;
              });
            },
            onDescriptionChanged: _onDescriptionChanged,
          ),
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
          FragmentTabsBar(snippet: snippet, controller: widget.controller),
          Expanded(
            child: CodeViewer(
              controller: _codeController,
              language: snippet.activeFragment.language,
            ),
          ),
        ],
      ),
    );
  }
}
