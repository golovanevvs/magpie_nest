import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magpie_nest/core/l10n/generated/app_localizations.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';

class FragmentTabsBar extends StatelessWidget {
  final Snippet snippet;
  final AppController controller;

  const FragmentTabsBar({
    super.key,
    required this.snippet,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (snippet.fragments.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ...snippet.fragments.map(
            (fragment) => FragmentTab(
              snippet: snippet,
              fragment: fragment,
              isActive: snippet.activeFragment.id == fragment.id,
              onTap: () =>
                  controller.setActiveFragment(snippet.id, fragment.id),
              onRename: (newName) => controller.updateFragmentName(
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
}

class FragmentTab extends StatefulWidget {
  final Snippet snippet;
  final Fragment fragment;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;

  const FragmentTab({
    super.key,
    required this.snippet,
    required this.fragment,
    required this.isActive,
    required this.onTap,
    required this.onRename,
  });

  @override
  State<FragmentTab> createState() => _FragmentTabState();
}

class _FragmentTabState extends State<FragmentTab> {
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
  void didUpdateWidget(covariant FragmentTab oldWidget) {
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
