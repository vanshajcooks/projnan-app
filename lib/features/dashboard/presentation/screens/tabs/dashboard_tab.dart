import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card.dart';

class DashboardTab extends ConsumerWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardTab({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final projectsState = ref.watch(projectsNotifierProvider);
    final tasksState = ref.watch(tasksNotifierProvider);
    final user = authState.user;

    final activeProjects = projectsState.projects.where((p) => !p.isCompleted).length;
    final pendingTasks = tasksState.pendingCount;
    final completedTasks = tasksState.completedCount;

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: () async {
        await Future.wait([
          ref.read(projectsNotifierProvider.notifier).fetchProjects(),
          ref.read(tasksNotifierProvider.notifier).fetchTasks(),
          ref.read(authNotifierProvider.notifier).checkAuthStatus(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.primary.withAlpha(45),
                      child: Text(
                        (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user?.name ?? 'Student',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(40),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  user?.role.toUpperCase() ?? 'STUDENT',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.rank ?? 'Level 1 Contributor',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // XP Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.zap, size: 14, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 4),
                            Text(
                              '${user?.xp ?? 0}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total XP',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Overview Metric Tiles
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Projects',
                    value: '$activeProjects',
                    icon: LucideIcons.folderGit2,
                    color: AppTheme.primary,
                    onTap: () => onNavigateToTab?.call(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Pending',
                    value: '$pendingTasks',
                    icon: LucideIcons.clock,
                    color: const Color(0xFFF97316),
                    onTap: () => onNavigateToTab?.call(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Completed',
                    value: '$completedTasks',
                    icon: LucideIcons.checkCircle2,
                    color: AppTheme.success,
                    onTap: () => onNavigateToTab?.call(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Recent Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Active Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab?.call(2),
                  child: const Text('View All', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (tasksState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            else if (tasksState.tasks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.clipboardCheck, size: 40, color: AppTheme.textSecondary.withAlpha(120)),
                        const SizedBox(height: 12),
                        const Text(
                          'No tasks assigned yet',
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...tasksState.tasks.take(4).map(
                    (task) => TaskCard(
                      task: task,
                      onStatusChange: (newStatus) {
                        ref.read(tasksNotifierProvider.notifier).updateStatus(task.id, newStatus);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
