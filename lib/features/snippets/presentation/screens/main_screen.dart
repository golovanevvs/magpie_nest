import 'package:material_ui/material_ui.dart';
import 'package:magpie_nest/core/sync/cloud_connection_controller.dart';
import 'package:magpie_nest/core/sync/sync_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/controllers/app_controller.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/dialogs/settings_dialog.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/sidebar/sidebar.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_list/snippet_list.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/snippet_preview/snippet_preview.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/panels/status_bar/status_bar.dart';
import 'package:magpie_nest/features/snippets/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final AppController controller;
  final CloudConnectionController cloud;
  final SyncController sync;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const MainScreen({
    super.key,
    required this.controller,
    required this.cloud,
    required this.sync,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: _sidebarWidth,
                      child: Sidebar(controller: widget.controller),
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
                    Expanded(child: SnippetPreview(controller: widget.controller)),
                  ],
                ),
              ),
              StatusBar(
                cloud: widget.cloud,
                sync: widget.sync,
                onCloudStatusTap: () => _openSettings(SettingsSection.cloud),
                onSettingsTap: () => _openSettings(SettingsSection.language),
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

  void _openSettings(SettingsSection section) {
    showSettingsDialog(
      context,
      cloud: widget.cloud,
      sync: widget.sync,
      currentLocale: widget.currentLocale,
      currentThemeMode: widget.themeMode,
      onLocaleChanged: widget.onLocaleChanged,
      onThemeModeChanged: widget.onThemeModeChanged,
      initialSection: section,
    );
  }
}
