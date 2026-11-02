import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/project_detail_controller.dart';

class AddFeedbackDialog extends ConsumerStatefulWidget {
  final int projectId;

  const AddFeedbackDialog({super.key, required this.projectId});

  static Future<void> show(BuildContext context, int projectId) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddFeedbackDialog(projectId: projectId),
    );
  }

  @override
  ConsumerState<AddFeedbackDialog> createState() => _AddFeedbackDialogState();
}

class _AddFeedbackDialogState extends ConsumerState<AddFeedbackDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;
  String _type = 'teacher_review';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      setState(() => _error = 'Please write an evaluation comment');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(projectDetailNotifierProvider(widget.projectId).notifier)
        .submitFeedback(comment, _rating, _type);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(context, 'Evaluation review submitted successfully!');
      } else {
        final err = ref.read(projectDetailNotifierProvider(widget.projectId)).errorMessage;
        setState(() => _error = err ?? 'Failed to submit review');
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
                    color: const Color(0xFFFBBF24).withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.star, size: 22, color: Color(0xFFFBBF24)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Evaluation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Post rubric rating & instructor review',
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

            // Rating Stars Bar
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isFilled = starIndex <= _rating;
                  return IconButton(
                    icon: Icon(
                      LucideIcons.star,
                      size: 28,
                      color: isFilled ? const Color(0xFFFBBF24) : AppTheme.border,
                    ),
                    onPressed: () => setState(() => _rating = starIndex),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Review Type Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeChip('teacher_review', 'Instructor Review'),
                const SizedBox(width: 10),
                _buildTypeChip('peer_review', 'Peer Review'),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Evaluation Feedback *',
                hintText: 'Code quality, progress velocity, recommendations...',
              ),
            ),
            const SizedBox(height: 24),

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
                        : const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label) {
    final isSelected = _type == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _type = value),
      selectedColor: AppTheme.primary.withAlpha(45),
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
      ),
    );
  }
}
