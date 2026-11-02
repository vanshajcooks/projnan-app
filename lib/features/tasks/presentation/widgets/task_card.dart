import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChange,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppTheme.error;
      case 'high':
        return const Color(0xFFF97316); // Orange
      case 'medium':
        return AppTheme.accent;
      case 'low':
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.success;
      case 'verification pending':
        return const Color(0xFFEAB308); // Yellow
      case 'in progress':
        return AppTheme.primaryLight;
      case 'planned':
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Priority Badge & XP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: priorityColor.withAlpha(90)),
                    ),
                    child: Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.zap, size: 12, color: AppTheme.primaryLight),
                        const SizedBox(width: 4),
                        Text(
                          '+${task.xpValue} XP',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),

              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bottom Row: Status Badge & Project Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Dropdown / Action
                  PopupMenuButton<String>(
                    tooltip: 'Change Status',
                    onSelected: (newStatus) {
                      onStatusChange?.call(newStatus);
                    },
                    itemBuilder: (context) => [
                      'Planned',
                      'In Progress',
                      'Verification Pending',
                      'Completed',
                    ]
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 13)),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isCompleted
                                ? LucideIcons.checkCircle2
                                : (task.isInProgress ? LucideIcons.clock : LucideIcons.circle),
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.chevronDown, size: 12, color: statusColor),
                        ],
                      ),
                    ),
                  ),

                  // Project Name
                  if (task.projectName != null)
                    Flexible(
                      child: Text(
                        task.projectName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
