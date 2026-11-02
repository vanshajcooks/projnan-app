import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = project.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Project Name & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone ? AppTheme.success.withAlpha(35) : AppTheme.primary.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDone ? AppTheme.success.withAlpha(100) : AppTheme.primary.withAlpha(100),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      project.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDone ? const Color(0xFF6EE7B7) : AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),

              if (project.description != null && project.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        '${project.progress}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress / 100.0,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? AppTheme.success : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Meta footer: Team name and Task count
              Row(
                children: [
                  if (project.teamName != null) ...[
                    const Icon(LucideIcons.users, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        project.teamName!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(LucideIcons.checkSquare, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    '${project.completedTaskCount}/${project.taskCount} tasks',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
