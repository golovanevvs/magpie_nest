import 'package:flutter/material.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/activity_bar/activity_bar.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/sidebar.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_list/snippet_list.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/snippet_preview.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final AppController controller;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const MainScreen({
    super.key,
    required this.controller,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0=Snippets, 1=Settings

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
              // Panel 1: Activity Bar
              SizedBox(
                height: double.infinity,
                child: ActivityBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _handleNavigationChange,
                ),
              ),
              const VerticalDivider(width: 1),

              if (_selectedIndex == 0) ...[
                // Panel 2: Sidebar
                SizedBox(
                  width: _sidebarWidth,
                  child: Sidebar(
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
                  child: SnippetList(controller: widget.controller),
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

                // Panel 4: Snippet Preview
                Expanded(
                  child: SnippetPreview(
                    selectedIndex: _selectedIndex,
                    controller: widget.controller,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: SettingsScreen(
                    currentLocale: widget.currentLocale,
                    currentThemeMode: widget.themeMode,
                    onLocaleChanged: widget.onLocaleChanged,
                    onThemeModeChanged: widget.onThemeModeChanged,
                  ),
                ),
              ],
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
      case 0: // Snippets
        widget.controller.selectFolder(null);
        break;
      case 1: // Settings
        // TODO: open settings panel
        break;
    }
  }
}
