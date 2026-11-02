import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/gamification_controller.dart';

class CompleteChallengeDialog extends ConsumerStatefulWidget {
  final int challengeId;
  final String challengeTitle;
  final int xpReward;

  const CompleteChallengeDialog({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.xpReward,
  });

  static Future<void> show(
    BuildContext context, {
    required int challengeId,
    required String challengeTitle,
    required int xpReward,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CompleteChallengeDialog(
        challengeId: challengeId,
        challengeTitle: challengeTitle,
        xpReward: xpReward,
      ),
    );
  }

  @override
  ConsumerState<CompleteChallengeDialog> createState() => _CompleteChallengeDialogState();
}

class _CompleteChallengeDialogState extends ConsumerState<CompleteChallengeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _evidenceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(gamificationNotifierProvider.notifier)
        .completeChallenge(widget.challengeId, _evidenceController.text.trim());

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        AppToast.showSuccess(
          context,
          'Challenge completed! +${widget.xpReward} XP awarded to your profile!',
        );
      } else {
        final err = ref.read(gamificationNotifierProvider).errorMessage;
        AppToast.showError(context, err ?? 'Failed to complete challenge.');
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
                      color: const Color(0xFFFBBF24).withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.swords, size: 22, color: Color(0xFFFBBF24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complete Challenge',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '+${widget.xpReward} XP Arena Reward',
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
              const SizedBox(height: 16),

              Text(
                widget.challengeTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _evidenceController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Proof of Completion *',
                  hintText: 'e.g. PR #15 merged, or commit sha, or brief description',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please provide proof of completion';
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
                    onPressed: _isSubmitting ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Claim Reward', style: TextStyle(fontWeight: FontWeight.bold)),
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
