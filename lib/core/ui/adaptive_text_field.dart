import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.decoration,
    this.errorText,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.textInputAction,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final InputDecoration? decoration;
  final String? errorText;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    if (designLanguage == DesignLanguage.fluent) {
      return fluentChrome(
        context,
        child: _withError(
          context,
          fluent.TextBox(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            placeholder: _placeholder,
            style: style,
            padding: _effectivePadding,
            prefix: decoration?.prefixIcon,
            suffix: decoration?.suffixIcon,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onTapOutside: onTapOutside,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: minLines,
            enabled: enabled,
            readOnly: readOnly,
            obscureText: obscureText,
          ),
        ),
      );
    }

    if (designLanguage == DesignLanguage.cupertino) {
      return _withError(
        context,
        cupertino.CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          placeholder: _placeholder,
          style: style,
          padding: _effectivePadding,
          prefix: decoration?.prefixIcon,
          suffix: decoration?.suffixIcon,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTapOutside: onTapOutside,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
        ),
      );
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: decoration,
      style: style,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
    );
  }

  Widget _withError(BuildContext context, Widget field) {
    final error = errorText ?? decoration?.errorText;
    if (error == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            error,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String? get _placeholder => decoration?.labelText ?? decoration?.hintText;

  EdgeInsetsGeometry get _effectivePadding {
    final contentPadding = decoration?.contentPadding;
    if (contentPadding != null) return contentPadding;
    if (decoration?.isDense ?? false) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    }
    return const EdgeInsets.all(8);
  }
}
