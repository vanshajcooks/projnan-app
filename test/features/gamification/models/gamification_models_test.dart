import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/features/gamification/data/models/achievement_model.dart';
import 'package:probon_app/features/gamification/data/models/arena_challenge_model.dart';
import 'package:probon_app/features/gamification/data/models/leaderboard_user_model.dart';

void main() {
  group('Gamification Models Tests', () {
    test('ArenaChallengeModel parses JSON and computes status booleans', () {
      final json = {
        'id': 1,
        'title': 'Fix a project issue',
        'description': 'Debug and submit a solution',
        'xp_reward': 200,
        'tag': 'Debugging',
        'difficulty': 'Medium',
        'user_status': 'available',
      };

      final challenge = ArenaChallengeModel.fromJson(json);

      expect(challenge.id, 1);
      expect(challenge.title, 'Fix a project issue');
      expect(challenge.xpReward, 200);
      expect(challenge.isAvailable, true);
      expect(challenge.isAccepted, false);
      expect(challenge.isCompleted, false);

      final accepted = ArenaChallengeModel.fromJson({
        ...json,
        'user_status': 'accepted',
      });
      expect(accepted.isAccepted, true);
      expect(accepted.isAvailable, false);

      final completed = ArenaChallengeModel.fromJson({
        ...json,
        'user_status': 'completed',
        'evidence': 'PR #12 merged',
      });
      expect(completed.isCompleted, true);
      expect(completed.evidence, 'PR #12 merged');
    });

    test('LeaderboardUserModel parses rankings and top three status', () {
      final json1 = {
        'id': 10,
        'name': 'Aryan Patel',
        'username': 'aryan',
        'role': 'student',
        'xp': 850,
        'points': 850,
        'rank': 'Contributor Level 3',
        'challenges_completed': 4,
        'contribution_count': 12,
        'position': 1,
      };

      final user1 = LeaderboardUserModel.fromJson(json1);
      expect(user1.position, 1);
      expect(user1.isTopThree, true);
      expect(user1.xp, 850);
      expect(user1.challengesCompleted, 4);

      final user4 = LeaderboardUserModel.fromJson({
        ...json1,
        'position': 4,
      });
      expect(user4.isTopThree, false);
    });

    test('AchievementModel parses badges and rewards', () {
      final json = {
        'id': 5,
        'user_id': 10,
        'title': 'Gladiator',
        'badge_icon': '⚔',
        'description': 'Completed your first Weekly Arena challenge',
        'xp_reward': 75,
        'unlocked_at': '2026-11-02T18:00:00Z',
      };

      final achievement = AchievementModel.fromJson(json);
      expect(achievement.id, 5);
      expect(achievement.title, 'Gladiator');
      expect(achievement.badgeIcon, '⚔');
      expect(achievement.xpReward, 75);
      expect(achievement.unlockedAt, '2026-11-02T18:00:00Z');
    });
  });
}
