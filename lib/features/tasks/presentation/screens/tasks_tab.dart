import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/core/utils/app_notifications.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card_skeleton.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_detail_bottom_sheet.dart';

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final tasks = tasksState.filteredTasks;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: ['All', 'Planned', 'In Progress', 'Completed'].map((filter) {
                final isSelected = tasksState.selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) {
                      ref.read(tasksNotifierProvider.notifier).setFilter(filter);
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Task List with Skeletons
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: () async {
                await ref.read(tasksNotifierProvider.notifier).fetchTasks();
              },
              child: tasksState.isLoading
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      itemCount: 4,
                      itemBuilder: (_, __) => const TaskCardSkeleton(),
                    )
                  : tasks.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.checkSquare,
                                    size: 48,
                                    color: AppTheme.textSecondary.withAlpha(100),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No tasks found',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tasks assigned to you will be listed here',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () {
                                TaskDetailBottomSheet.show(
                                  context,
                                  task: task,
                                  onStatusChange: (tId, newStatus) {
                                    return ref.read(tasksNotifierProvider.notifier).updateStatus(tId, newStatus);
                                  },
                                );
                              },
                              onStatusChange: (newStatus) async {
                                final success = await ref
                                    .read(tasksNotifierProvider.notifier)
                                    .updateStatus(task.id, newStatus);
                                if (success && context.mounted) {
                                  AppToast.showSuccess(context, 'Task status updated to $newStatus');
                                }
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
