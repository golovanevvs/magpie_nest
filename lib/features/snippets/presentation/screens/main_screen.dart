import 'package:flutter/material.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/navigation_rail_panel.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar_panel.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_list_panel.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_viewer_panel.dart';

/// Main screen with a four-panel layout (similar to massCode).
///
/// Layout structure:
/// 1. Navigation Rail (leftmost) - switches between Library, All Snippets, Favorites, Trash
/// 2. Sidebar - shows folders (in Library mode) or section info
/// 3. Snippet List - shows snippets in the selected folder/section
/// 4. Snippet Viewer (rightmost) - displays the selected snippet's content
class MainScreen extends StatefulWidget {
  final AppController controller;

  const MainScreen({super.key, required this.controller});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0=Library, 1=All Snippets, 2=Favorites, 3=Trash

  double _sidebarWidth = 200;
  double _snippetListWidth = 300;

  static const double _minSidebarWidth = 120;
  static const double _maxSidebarWidth = 400;
  static const double _minSnippetListWidth = 150;
  static const double _maxSnippetListWidth = 600;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Scaffold(
          body: Row(
            children: [
              // Panel 1: Navigation Rail
              NavigationRailPanel(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _handleNavigationChange,
              ),
              const VerticalDivider(width: 1),

              // Panel 2: Sidebar
              SizedBox(
                width: _sidebarWidth,
                child: SidebarPanel(
                  selectedIndex: _selectedIndex,
                  controller: widget.controller,
                ),
              ),
              _buildResizableDivider(
                onDrag: (delta) {
                  setState(() {
                    _sidebarWidth = _clamp(
                      _sidebarWidth + delta,
                      _minSidebarWidth,
                      _maxSidebarWidth,
                    );
                  });
                },
              ),

              // Panel 3: Snippet List
              SizedBox(
                width: _snippetListWidth,
                child: SnippetListPanel(controller: widget.controller),
              ),
              _buildResizableDivider(
                onDrag: (delta) {
                  setState(() {
                    _snippetListWidth = _clamp(
                      _snippetListWidth + delta,
                      _minSnippetListWidth,
                      _maxSnippetListWidth,
                    );
                  });
                },
              ),

              // Panel 4: Snippet Viewer
              Expanded(
                child: SnippetViewerPanel(
                  selectedIndex: _selectedIndex,
                  controller: widget.controller,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResizableDivider({required ValueChanged<double> onDrag}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 8,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: const VerticalDivider(width: 1),
        ),
      ),
    );
  }

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _handleNavigationChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Library
      case 1: // All Snippets
        widget.controller.selectFolder(null);
        break;
      case 2: // Favorites
        widget.controller.selectSection(SidebarSection.favorites);
        break;
      case 3: // Trash
        widget.controller.selectSection(SidebarSection.trash);
        break;
    }
  }
}
