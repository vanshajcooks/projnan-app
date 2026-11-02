import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../data/models/task_model.dart';
import '../controllers/tasks_controller.dart';
import 'submit_evidence_dialog.dart';
import 'verify_task_dialog.dart';

class TaskDetailBottomSheet extends ConsumerWidget {
  final TaskModel task;
  final Future<bool> Function(int taskId, String newStatus)? onStatusChange;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    this.onStatusChange,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskModel task,
    Future<bool> Function(int taskId, String newStatus)? onStatusChange,
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

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
      final success = await ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        if (success) {
          AppToast.showSuccess(context, 'Task deleted successfully.');
        } else {
          AppToast.showError(context, 'Failed to delete task.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SingleChildScrollView(
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
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: AppTheme.error),
                        tooltip: 'Delete Task',
                        onPressed: () => _handleDelete(context, ref),
                      ),
                    ],
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

              const SizedBox(height: 16),

              // Evidence & Verification Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.fileCheck2, size: 16, color: AppTheme.primaryLight),
                            SizedBox(width: 6),
                            Text(
                              'Proof of Work & Evidence',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        if (task.isPendingVerification)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withAlpha(35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Pending Review',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
                            ),
                          )
                        else if (task.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withAlpha(35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (task.hasEvidence) ...[
                      Text(
                        task.completionEvidence!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight, height: 1.3),
                      ),
                      const SizedBox(height: 10),
                    ] else
                      const Text(
                        'No evidence submitted yet. Provide a GitHub PR link or commit hash for teacher verification.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(LucideIcons.uploadCloud, size: 14),
                            label: Text(
                              task.hasEvidence ? 'Update Evidence' : 'Submit Evidence',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary),
                              foregroundColor: AppTheme.primaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              SubmitEvidenceDialog.show(context, taskId: task.id, taskTitle: task.title);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(LucideIcons.shieldCheck, size: 14),
                            label: const Text(
                              'Teacher Verify',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFBBF24)),
                              foregroundColor: const Color(0xFFFBBF24),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              VerifyTaskDialog.show(context, task: task);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
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
                          if (onStatusChange != null) {
                            final success = await onStatusChange!(task.id, 'In Progress');
                            if (success && context.mounted) {
                              AppToast.showSuccess(context, 'Task set to In Progress');
                            }
                          } else {
                            final success = await ref
                                .read(tasksNotifierProvider.notifier)
                                .updateStatus(task.id, 'In Progress');
                            if (success && context.mounted) {
                              AppToast.showSuccess(context, 'Task set to In Progress');
                            }
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
                          if (onStatusChange != null) {
                            final success = await onStatusChange!(task.id, 'Completed');
                            if (success && context.mounted) {
                              AppToast.showSuccess(context, 'Task marked as Completed! (+${task.xpValue} XP)');
                            }
                          } else {
                            final success = await ref
                                .read(tasksNotifierProvider.notifier)
                                .updateStatus(task.id, 'Completed');
                            if (success && context.mounted) {
                              AppToast.showSuccess(context, 'Task marked as Completed! (+${task.xpValue} XP)');
                            }
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
      ),
    );
  }
}
