import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as sdk;
import 'package:flutter_localizations/flutter_localizations.dart' as sdk_l10n;
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/ui/adaptive_icon_button.dart';
import 'package:magpie_nest/core/ui/adaptive_snack_bar.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/language_mapper.dart';

class CodeViewer extends StatelessWidget {
  final CodeLineEditingController controller;
  final String language;

  const CodeViewer({
    super.key,
    required this.controller,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editorBackground = isDark
        ? const Color(0xFF282C34)
        : const Color(0xFFFAFAFA);
    final headerBackground = isDark
        ? const Color(0xFF21252B)
        : const Color(0xFFEDEDED);
    final headerForeground = isDark ? Colors.white70 : Colors.black54;

    final mode = codeLanguageMode(language);
    final theme = isDark ? atomOneDarkTheme : atomOneLightTheme;

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
                AdaptiveIconButton(
                  icon: Icon(Icons.copy, color: headerForeground, size: 18),
                  tooltip: l10n.buttonCopy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller.text));
                    showAdaptiveSnackBar(
                      context,
                      message: l10n.snackbarCopied,
                      duration: const Duration(seconds: 1),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: sdk.Theme(
              data: sdk.ThemeData(
                brightness:
                    isDark ? sdk.Brightness.dark : sdk.Brightness.light,
              ),
              child: sdk.Localizations.override(
                context: context,
                delegates: const [
                  sdk_l10n.GlobalMaterialLocalizations.delegate,
                  sdk_l10n.GlobalWidgetsLocalizations.delegate,
                ],
                child: sdk.Material(
                  type: sdk.MaterialType.transparency,
                  child: CodeEditor(
                    controller: controller,
                    style: CodeEditorStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontHeight: 1.5,
                      textColor: isDark ? Colors.white : Colors.black87,
                      cursorColor: isDark ? Colors.white : Colors.black87,
                      cursorLineColor: isDark
                          ? const Color(0xFF282C34)
                          : const Color(0xFFFAFAFA),
                      selectionColor: isDark
                          ? const Color(0x3348A7E9)
                          : const Color(0x33009688),
                      highlightColor: isDark
                          ? const Color(0x3348A7E9)
                          : const Color(0x33009688),
                      codeTheme: mode == null
                          ? null
                          : CodeHighlightTheme(
                              languages: {
                                language: CodeHighlightThemeMode(mode: mode),
                              },
                              theme: theme,
                            ),
                    ),
                    indicatorBuilder:
                        (context, editingController, chunkController, notifier) {
                      return Row(
                        children: [
                          DefaultCodeLineNumber(
                            controller: editingController,
                            notifier: notifier,
                          ),
                          DefaultCodeChunkIndicator(
                            width: 16,
                            controller: chunkController,
                            notifier: notifier,
                          ),
                        ],
                      );
                    },
                    chunkAnalyzer: DefaultCodeChunkAnalyzer(),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
