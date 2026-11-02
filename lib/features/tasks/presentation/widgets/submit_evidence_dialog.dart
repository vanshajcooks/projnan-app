import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/tasks_controller.dart';

class SubmitEvidenceDialog extends ConsumerStatefulWidget {
  final int taskId;
  final String taskTitle;

  const SubmitEvidenceDialog({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  static Future<void> show(BuildContext context, {required int taskId, required String taskTitle}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SubmitEvidenceDialog(taskId: taskId, taskTitle: taskTitle),
    );
  }

  @override
  ConsumerState<SubmitEvidenceDialog> createState() => _SubmitEvidenceDialogState();
}

class _SubmitEvidenceDialogState extends ConsumerState<SubmitEvidenceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _evidenceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(tasksNotifierProvider.notifier)
        .submitEvidence(widget.taskId, _evidenceController.text.trim());

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context,
          'Evidence submitted! Task moved to Verification Pending.',
        );
      } else {
        final err = ref.read(tasksNotifierProvider).errorMessage;
        AppToast.showError(context, err ?? 'Failed to submit evidence.');
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
        child: Form(
          key: _formKey,
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
                      color: AppTheme.primary.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.fileCheck, size: 22, color: AppTheme.primaryLight),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Task Evidence',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Link PR or explain completion',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Task: ${widget.taskTitle}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _evidenceController,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Evidence / PR Link / Commit SHA *',
                  hintText: 'e.g. PR #42 merged: https://github.com/org/repo/pull/42 or SHA abc1234',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 50.0),
                    child: Icon(LucideIcons.link2, size: 18),
                  ),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Evidence or proof link is required';
                  }
                  return null;
                },
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
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
                        : const Text('Submit Evidence', style: TextStyle(fontWeight: FontWeight.bold)),
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
