import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/achievement_model.dart';

class AchievementBadgeCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementBadgeCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Badge Emoji Container
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFBBF24).withAlpha(100), width: 1.5),
              ),
              child: Text(
                achievement.badgeIcon,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),

            // XP reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.zap, size: 12, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 3),
                  Text(
                    '+${achievement.xpReward}',
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
      ),
    );
  }
}
