import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/project_model.dart';

class ProjectDetailBottomSheet extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailBottomSheet({
    super.key,
    required this.project,
  });

  static Future<void> show(BuildContext context, ProjectModel project) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => ProjectDetailBottomSheet(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = project.isCompleted;

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

            // Header: Status badge & Class name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone ? AppTheme.success.withAlpha(35) : AppTheme.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDone ? AppTheme.success.withAlpha(100) : AppTheme.primary.withAlpha(100),
                    ),
                  ),
                  child: Text(
                    project.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDone ? const Color(0xFF6EE7B7) : AppTheme.primaryLight,
                    ),
                  ),
                ),
                if (project.className != null)
                  Text(
                    project.className!,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            if (project.teamName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    project.teamName!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overall Progress', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${project.progress}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: project.progress / 100.0,
                minHeight: 8,
                backgroundColor: AppTheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDone ? AppTheme.success : AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'About Project',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              project.description != null && project.description!.isNotEmpty
                  ? project.description!
                  : 'No description provided.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4),
            ),

            // Goals list if available
            if (project.goals.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Key Goals',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              ...project.goals.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.check, size: 14, color: AppTheme.primaryLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          g,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Tags if available
            if (project.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: project.tags.map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ),
                ).toList(),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/projects/${project.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(LucideIcons.layoutDashboard, size: 18),
                label: const Text(
                  'Open Command Center',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
