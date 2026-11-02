import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/gamification/data/models/achievement_model.dart';
import 'package:probon_app/features/gamification/data/models/arena_challenge_model.dart';
import 'package:probon_app/features/gamification/data/models/leaderboard_user_model.dart';
import 'package:probon_app/features/gamification/data/repositories/gamification_repository.dart';
import 'package:probon_app/features/gamification/presentation/controllers/gamification_controller.dart';

class MockGamificationRepository extends Mock implements IGamificationRepository {}

void main() {
  late MockGamificationRepository mockRepo;
  late ProviderContainer container;

  final sampleChallenges = [
    const ArenaChallengeModel(
      id: 1,
      title: 'Fix a project issue',
      description: 'Debug and submit a solution',
      xpReward: 200,
      userStatus: 'available',
    ),
    const ArenaChallengeModel(
      id: 2,
      title: 'Improve existing code',
      description: 'Refactor component',
      xpReward: 150,
      userStatus: 'accepted',
    ),
  ];

  final sampleLeaderboard = [
    const LeaderboardUserModel(
      id: 10,
      name: 'Aryan Patel',
      username: 'aryan',
      xp: 850,
      position: 1,
    ),
  ];

  final sampleAchievements = [
    const AchievementModel(
      id: 1,
      title: 'Gladiator',
      badgeIcon: '⚔',
      description: 'Completed your first Weekly Arena challenge',
      xpReward: 75,
    ),
  ];

  setUp(() {
    mockRepo = MockGamificationRepository();
    container = ProviderContainer(
      overrides: [
        gamificationRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('GamificationNotifier Tests', () {
    test('loadAll populates challenges, leaderboard, and achievements', () async {
      when(() => mockRepo.getArenaChallenges()).thenAnswer((_) async => sampleChallenges);
      when(() => mockRepo.getLeaderboard(limit: any(named: 'limit'))).thenAnswer((_) async => sampleLeaderboard);
      when(() => mockRepo.getAchievements()).thenAnswer((_) async => sampleAchievements);

      final notifier = container.read(gamificationNotifierProvider.notifier);
      await notifier.loadAll();

      final state = container.read(gamificationNotifierProvider);
      expect(state.isLoading, false);
      expect(state.challenges.length, 2);
      expect(state.leaderboard.length, 1);
      expect(state.achievements.length, 1);
    });

    test('acceptChallenge updates challenge state to accepted', () async {
      when(() => mockRepo.getArenaChallenges()).thenAnswer((_) async => sampleChallenges);
      when(() => mockRepo.getLeaderboard(limit: any(named: 'limit'))).thenAnswer((_) async => sampleLeaderboard);
      when(() => mockRepo.getAchievements()).thenAnswer((_) async => sampleAchievements);
      when(() => mockRepo.acceptChallenge(1)).thenAnswer((_) async => true);

      final notifier = container.read(gamificationNotifierProvider.notifier);
      await notifier.loadAll();

      final success = await notifier.acceptChallenge(1);
      expect(success, true);

      final c1 = container.read(gamificationNotifierProvider).challenges.firstWhere((c) => c.id == 1);
      expect(c1.isAccepted, true);
    });

    test('completeChallenge updates challenge to completed and refreshes rewards', () async {
      when(() => mockRepo.getArenaChallenges()).thenAnswer((_) async => sampleChallenges);
      when(() => mockRepo.getLeaderboard(limit: any(named: 'limit'))).thenAnswer((_) async => sampleLeaderboard);
      when(() => mockRepo.getAchievements()).thenAnswer((_) async => sampleAchievements);
      when(() => mockRepo.completeChallenge(2, evidence: 'PR #10')).thenAnswer((_) async => {'success': true});

      final notifier = container.read(gamificationNotifierProvider.notifier);
      await notifier.loadAll();

      final success = await notifier.completeChallenge(2, 'PR #10');
      expect(success, true);

      final c2 = container.read(gamificationNotifierProvider).challenges.firstWhere((c) => c.id == 2);
      expect(c2.isCompleted, true);
    });
  });
}
