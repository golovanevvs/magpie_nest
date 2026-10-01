import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';

class CodeViewer extends StatelessWidget {
  final CodeController controller;
  final String language;

  const CodeViewer({
    super.key,
    required this.controller,
    required this.language,
  });

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
    final lineCount = controller.text.split('\n').length;
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
                  language,
                  style: TextStyle(color: headerForeground, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.copy, color: headerForeground, size: 18),
                  tooltip: l10n.buttonCopy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller.text));
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
                controller: controller,
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
}
