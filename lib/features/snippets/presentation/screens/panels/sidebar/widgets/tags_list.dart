import 'package:flutter/material.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/widgets/sidebar_item.dart';

class TagsList extends StatelessWidget {
  final AppController controller;

  const TagsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tags = controller.tags.toList()..sort();
    final selectedTag = controller.selectedTag;

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final isSelected = selectedTag == tag;
        return SidebarItem(
          icon: Icons.tag,
          label: tag,
          selected: isSelected,
          onTap: () => controller.selectTag(isSelected ? null : tag),
        );
      },
    );
  }
}
