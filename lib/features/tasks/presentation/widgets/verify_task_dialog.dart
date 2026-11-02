import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../data/models/task_model.dart';
import '../controllers/tasks_controller.dart';

class VerifyTaskDialog extends ConsumerStatefulWidget {
  final TaskModel task;

  const VerifyTaskDialog({super.key, required this.task});

  static Future<void> show(BuildContext context, {required TaskModel task}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyTaskDialog(task: task),
    );
  }

  @override
  ConsumerState<VerifyTaskDialog> createState() => _VerifyTaskDialogState();
}

class _VerifyTaskDialogState extends ConsumerState<VerifyTaskDialog> {
  bool _isApproved = true;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);
    final success = await ref.read(tasksNotifierProvider.notifier).verifyTask(
          widget.task.id,
          approved: _isApproved,
          feedbackNote: _feedbackController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context,
          _isApproved
              ? 'Task verified & confirmed! XP awarded to student.'
              : 'Task returned to In Progress for revision.',
        );
      } else {
        final err = ref.read(tasksNotifierProvider).errorMessage;
        AppToast.showError(context, err ?? 'Failed to verify task.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.shieldCheck, size: 22, color: Color(0xFFFBBF24)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teacher Verification',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Review submitted work & evidence',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Task title & XP
              Container(
                padding: const EdgeInsets.all(12),
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
                        Expanded(
                          child: Text(
                            widget.task.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${widget.task.xpValue} XP',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
                          ),
                        ),
                      ],
                    ),
                    if (widget.task.completionEvidence != null && widget.task.completionEvidence!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Submitted Evidence:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.task.completionEvidence!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight, height: 1.3),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Decision Toggle
              const Text(
                'Decision',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isApproved = true),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isApproved ? AppTheme.success.withAlpha(40) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isApproved ? AppTheme.success : AppTheme.border,
                            width: _isApproved ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.checkCircle2,
                              size: 16,
                              color: _isApproved ? AppTheme.success : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isApproved ? AppTheme.success : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isApproved = false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isApproved ? AppTheme.error.withAlpha(40) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: !_isApproved ? AppTheme.error : AppTheme.border,
                            width: !_isApproved ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.xCircle,
                              size: 16,
                              color: !_isApproved ? AppTheme.error : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !_isApproved ? AppTheme.error : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Feedback Note
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: _isApproved ? 'Commendation Note (Optional)' : 'Revision Instructions *',
                  hintText: _isApproved
                      ? 'e.g. Excellent test suite and clean code!'
                      : 'e.g. Please add integration tests for the API routes.',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isApproved ? AppTheme.success : AppTheme.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isApproved ? 'Confirm Approval' : 'Return for Revision',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
