import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/core/utils/app_notifications.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:probon_app/features/tasks/presentation/widgets/create_task_bottom_sheet.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_card_skeleton.dart';
import 'package:probon_app/features/tasks/presentation/widgets/task_detail_bottom_sheet.dart';

class TasksTab extends ConsumerStatefulWidget {
  const TasksTab({super.key});

  @override
  ConsumerState<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends ConsumerState<TasksTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tasksNotifierProvider.notifier).fetchTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final tasks = tasksState.filteredTasks;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusSquare, size: 20),
            tooltip: 'New Task',
            onPressed: () => CreateTaskBottomSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scope Toggle: My Tasks vs All Team Tasks
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => ref.read(tasksNotifierProvider.notifier).toggleScope(true),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tasksState.showOnlyMyTasks ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: tasksState.showOnlyMyTasks ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => ref.read(tasksNotifierProvider.notifier).toggleScope(false),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !tasksState.showOnlyMyTasks ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'All Team Tasks',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: !tasksState.showOnlyMyTasks ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(tasksNotifierProvider.notifier).setSearchQuery(val),
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search tasks by title, project...',
                hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppTheme.textSecondary),
                suffixIcon: tasksState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 14),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(tasksNotifierProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
            ),
          ),

          // Status & Priority Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Row(
              children: [
                ...['All', 'Planned', 'In Progress', 'Verification Pending', 'Completed'].map((filter) {
                  final isSelected = tasksState.selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) => ref.read(tasksNotifierProvider.notifier).setFilter(filter),
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Container(height: 20, width: 1, color: AppTheme.border),
                const SizedBox(width: 8),
                // Priority chips
                ...['All', 'Urgent', 'High', 'Medium', 'Low'].map((prio) {
                  final isSelected = tasksState.selectedPriority.toLowerCase() == prio.toLowerCase();
                  Color prioColor = AppTheme.textSecondary;
                  if (prio == 'Urgent') prioColor = AppTheme.error;
                  if (prio == 'High') prioColor = const Color(0xFFF97316);
                  if (prio == 'Medium') prioColor = const Color(0xFF38BDF8);
                  if (prio == 'Low') prioColor = const Color(0xFF10B981);

                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      label: Text(prio == 'All' ? 'All Priority' : prio),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) => ref.read(tasksNotifierProvider.notifier).setPriorityFilter(prio),
                      selectedColor: prioColor.withAlpha(45),
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? prioColor : AppTheme.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isSelected ? prioColor : AppTheme.border),
                      ),
                    ),
                  );
                }),
              ],
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
                      itemBuilder: (context, index) => const TaskCardSkeleton(),
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
                                  Text(
                                    tasksState.showOnlyMyTasks ? 'No tasks assigned to you' : 'No tasks found',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tasksState.showOnlyMyTasks
                                        ? 'Collaborative deliverables will appear here'
                                        : 'Create a task or change the filter',
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateTaskBottomSheet.show(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
