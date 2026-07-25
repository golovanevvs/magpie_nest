import 'package:flutter/material.dart';

/// Section header used inside the sidebar.
class SidebarSectionHeader extends StatelessWidget {
  final String title;

  const SidebarSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
