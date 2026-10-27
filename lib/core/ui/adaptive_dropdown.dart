import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_ui/material_ui.dart';

import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/core/platform/design_language.dart';
import 'package:magpie_nest/core/ui/adaptive_theme.dart';

class AdaptiveDropdownItem<T> {
  const AdaptiveDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

class AdaptiveDropdown<T> extends StatelessWidget {
  const AdaptiveDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.isExpanded = false,
    this.label,
  });

  final T? value;
  final List<AdaptiveDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isExpanded;

  final String? label;

  @override
  Widget build(BuildContext context) {
    final designLanguage = designLanguageFor(Theme.of(context).platform);

    Widget control;
    if (designLanguage == DesignLanguage.fluent) {
      control = fluentChrome(
        context,
        child: fluent.ComboBox<T>(
          value: value,
          items: items
              .map(
                (item) => fluent.ComboBoxItem<T>(
                  value: item.value,
                  child: Text(item.label),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      );
    } else if (designLanguage == DesignLanguage.cupertino) {
      control = cupertino.CupertinoButton(
        onPressed: () => _showCupertinoPicker(context),
        sizeStyle: cupertino.CupertinoButtonSize.medium,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                items.firstWhere((item) => item.value == value).label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(cupertino.CupertinoIcons.chevron_down, size: 14),
          ],
        ),
      );
    } else {
      control = DropdownButton<T>(
        value: value,
        isDense: true,
        isExpanded: isExpanded,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item.value,
                child: Text(item.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
      );
    }

    final caption = label;
    if (caption == null) return control;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          caption,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        control,
      ],
    );
  }

  Future<void> _showCupertinoPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final initialIndex = items.indexWhere((item) => item.value == value);
    final controller = FixedExtentScrollController(
      initialItem: initialIndex < 0 ? 0 : initialIndex,
    );
    T? selected = value;

    await cupertino.showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => Container(
        height: 216,
        color: cupertino.CupertinoDynamicColor.resolve(
          cupertino.CupertinoColors.systemBackground,
          popupContext,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: cupertino.CupertinoButton(
                  onPressed: () => Navigator.of(popupContext).pop(),
                  child: Text(l10n.dialogDone),
                ),
              ),
              Expanded(
                child: cupertino.CupertinoPicker(
                  itemExtent: 32,
                  scrollController: controller,
                  onSelectedItemChanged: (index) {
                    selected = items[index].value;
                  },
                  children: items
                      .map((item) => Text(item.label))
                      .toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    controller.dispose();
    if (selected != value) {
      onChanged(selected);
    }
  }
}
