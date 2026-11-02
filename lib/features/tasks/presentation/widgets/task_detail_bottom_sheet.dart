import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../data/models/task_model.dart';

class TaskDetailBottomSheet extends StatelessWidget {
  final TaskModel task;
  final Future<bool> Function(int taskId, String newStatus) onStatusChange;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    required this.onStatusChange,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskModel task,
    required Future<bool> Function(int taskId, String newStatus) onStatusChange,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => TaskDetailBottomSheet(
        task: task,
        onStatusChange: onStatusChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Priority & Status header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.zap, size: 13, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 4),
                      Text(
                        '+${task.xpValue} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            if (task.projectName != null) ...[
              const SizedBox(height: 4),
              Text(
                task.projectName!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              task.description != null && task.description!.isNotEmpty
                  ? task.description!
                  : 'No detailed description provided for this task.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Status Action Section
            const Text(
              'Update Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                if (task.status != 'In Progress')
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryLight,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final success = await onStatusChange(task.id, 'In Progress');
                        if (success && context.mounted) {
                          AppToast.showSuccess(context, 'Task set to In Progress');
                        }
                      },
                      child: const Text('Start Task', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                if (task.status != 'In Progress') const SizedBox(width: 10),
                if (!task.isCompleted)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final success = await onStatusChange(task.id, 'Completed');
                        if (success && context.mounted) {
                          AppToast.showSuccess(context, 'Task marked as Completed! (+${task.xpValue} XP)');
                        }
                      },
                      child: const Text('Complete Task', style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
