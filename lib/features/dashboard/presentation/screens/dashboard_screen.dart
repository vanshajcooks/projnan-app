import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/projects/presentation/screens/projects_tab.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/screens/tasks_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectsNotifierProvider.notifier).fetchProjects();
      ref.read(tasksNotifierProvider.notifier).fetchTasks();
    });
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
