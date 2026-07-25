import 'package:flutter/material.dart';
import 'package:magpie_nest/core/constants/languages.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';

class CreateSnippetDialog extends StatefulWidget {
  const CreateSnippetDialog({super.key});

  @override
  State<CreateSnippetDialog> createState() => _CreateSnippetDialogState();
}

class _CreateSnippetDialogState extends State<CreateSnippetDialog> {
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedLanguage = 'plaintext';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.dialogCreateSnippetTitle),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.fieldSnippetName,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              decoration: InputDecoration(
                labelText: l10n.fieldLanguage,
                border: const OutlineInputBorder(),
              ),
              items: SupportedLanguages.allWithNames.map((lang) {
                return DropdownMenuItem(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: l10n.fieldContent,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final content = _contentController.text;

            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.errorNameRequired)));
              return;
            }

            final snippet = Snippet(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              content: content,
              language: _selectedLanguage,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            Navigator.of(context).pop(snippet);
          },
          child: Text(l10n.dialogCreate),
        ),
      ],
    );
  }
}
