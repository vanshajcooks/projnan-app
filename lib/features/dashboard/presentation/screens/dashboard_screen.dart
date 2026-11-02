import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/classes/presentation/controllers/classes_controller.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/projects/presentation/screens/projects_tab.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/screens/tasks_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const DashboardScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectsNotifierProvider.notifier).fetchProjects();
      ref.read(tasksNotifierProvider.notifier).fetchTasks();
      ref.read(classesNotifierProvider.notifier).fetchClassesAndTeams();
    });
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _currentIndex = widget.initialTab.clamp(0, 3);
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardTab(onNavigateToTab: _onTabTapped),
      const ProjectsTab(),
      const TasksTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary.withAlpha(45),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard, size: 20),
              selectedIcon: Icon(LucideIcons.layoutDashboard, size: 20, color: AppTheme.primaryLight),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.folder, size: 20),
              selectedIcon: Icon(LucideIcons.folder, size: 20, color: AppTheme.primaryLight),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.checkSquare, size: 20),
              selectedIcon: Icon(LucideIcons.checkSquare, size: 20, color: AppTheme.primaryLight),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.user, size: 20),
              selectedIcon: Icon(LucideIcons.user, size: 20, color: AppTheme.primaryLight),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
