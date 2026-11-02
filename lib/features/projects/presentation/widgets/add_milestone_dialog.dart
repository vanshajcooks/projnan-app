import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/project_detail_controller.dart';

class AddMilestoneDialog extends ConsumerStatefulWidget {
  final int projectId;

  const AddMilestoneDialog({super.key, required this.projectId});

  static Future<void> show(BuildContext context, int projectId) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddMilestoneDialog(projectId: projectId),
    );
  }

  @override
  ConsumerState<AddMilestoneDialog> createState() => _AddMilestoneDialogState();
}

class _AddMilestoneDialogState extends ConsumerState<AddMilestoneDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _xpReward = 100;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a milestone title');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(projectDetailNotifierProvider(widget.projectId).notifier)
        .addMilestone(
          title,
          _descController.text.trim(),
          _xpReward,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'Milestone "$title" added (+$_xpReward XP)!');
      } else {
        final err = ref.read(projectDetailNotifierProvider(widget.projectId)).errorMessage;
        setState(() => _error = err ?? 'Failed to add milestone');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.flag, size: 22, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Milestone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Set project targets and XP bonuses',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withAlpha(70)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 16, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Milestone Title *',
                hintText: 'e.g. Beta Release 1.0',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Deliverables Summary',
                hintText: 'Key features required to complete...',
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(LucideIcons.zap, size: 16, color: Color(0xFFFBBF24)),
                const SizedBox(width: 8),
                const Text(
                  'Completion Bonus:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Text(
                  '$_xpReward XP',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
                ),
              ],
            ),
            Slider(
              value: _xpReward.toDouble(),
              min: 50,
              max: 500,
              divisions: 9,
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.border,
              onChanged: (val) => setState(() => _xpReward = val.round()),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Add Milestone'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
