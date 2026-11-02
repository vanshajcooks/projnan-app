import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../../data/models/arena_challenge_model.dart';
import '../controllers/gamification_controller.dart';
import 'complete_challenge_dialog.dart';

class ArenaChallengeCard extends ConsumerWidget {
  final ArenaChallengeModel challenge;

  const ArenaChallengeCard({super.key, required this.challenge});

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return AppTheme.success;
      case 'hard':
        return AppTheme.error;
      case 'medium':
      default:
        return const Color(0xFFF97316);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diffColor = _getDifficultyColor(challenge.difficulty);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: diffColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: diffColor.withAlpha(90)),
                      ),
                      child: Text(
                        challenge.difficulty.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: diffColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        challenge.tag,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.zap, size: 12, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 4),
                      Text(
                        '+${challenge.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title & Description
            Text(
              challenge.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              challenge.description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Action / Status Row
            if (challenge.isCompleted) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success.withAlpha(80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.checkCircle2, size: 14, color: AppTheme.success),
                    SizedBox(width: 6),
                    Text(
                      'Completed & Claimed',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success),
                    ),
                  ],
                ),
              ),
            ] else if (challenge.isAccepted) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.hourglass, size: 13, color: AppTheme.primaryLight),
                        SizedBox(width: 5),
                        Text(
                          'In Progress',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryLight),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      CompleteChallengeDialog.show(
                        context,
                        challengeId: challenge.id,
                        challengeTitle: challenge.title,
                        xpReward: challenge.xpReward,
                      );
                    },
                    icon: const Icon(LucideIcons.check, size: 14),
                    label: const Text('Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ] else ...[
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () async {
                    final success = await ref
                        .read(gamificationNotifierProvider.notifier)
                        .acceptChallenge(challenge.id);
                    if (success && context.mounted) {
                      AppToast.showSuccess(context, 'Challenge accepted! Complete it to earn XP.');
                    }
                  },
                  icon: const Icon(LucideIcons.play, size: 13),
                  label: const Text('Accept Challenge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
