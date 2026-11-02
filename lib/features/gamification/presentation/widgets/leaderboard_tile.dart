import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/leaderboard_user_model.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardUserModel user;

  const LeaderboardTile({super.key, required this.user});

  Color _getPositionBadgeColor(int pos) {
    switch (pos) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posColor = _getPositionBadgeColor(user.position);
    final isTop = user.isTopThree;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Position Badge
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTop ? posColor.withAlpha(40) : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTop ? posColor : AppTheme.border,
                  width: isTop ? 1.5 : 1,
                ),
              ),
              child: Text(
                '#${user.position}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isTop ? posColor : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar placeholder
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withAlpha(40),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.rank,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // XP and points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.zap, size: 13, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 3),
                    Text(
                      '${user.xp} XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.challengesCompleted} challenges',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
