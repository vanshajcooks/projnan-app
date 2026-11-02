import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/gamification/data/models/achievement_model.dart';
import 'package:probon_app/features/gamification/data/models/arena_challenge_model.dart';
import 'package:probon_app/features/gamification/data/models/leaderboard_user_model.dart';
import 'package:probon_app/features/gamification/data/repositories/gamification_repository.dart';
import 'package:probon_app/features/gamification/presentation/controllers/gamification_controller.dart';
import 'package:probon_app/features/gamification/presentation/screens/weekly_arena_screen.dart';

class MockGamificationRepository extends Mock implements IGamificationRepository {}

void main() {
  late MockGamificationRepository mockRepo;

  final sampleChallenges = [
    const ArenaChallengeModel(
      id: 1,
      title: 'Fix a project issue',
      description: 'Debug and submit a solution',
      xpReward: 200,
      difficulty: 'Medium',
      tag: 'Debugging',
      userStatus: 'available',
    ),
    const ArenaChallengeModel(
      id: 2,
      title: 'Improve existing code',
      description: 'Refactor component for testability',
      xpReward: 150,
      difficulty: 'Easy',
      tag: 'Refactor',
      userStatus: 'accepted',
    ),
  ];

  final sampleLeaderboard = [
    const LeaderboardUserModel(
      id: 10,
      name: 'Aryan Patel',
      username: 'aryan',
      xp: 850,
      rank: 'Senior Contributor',
      challengesCompleted: 3,
      position: 1,
    ),
    const LeaderboardUserModel(
      id: 11,
      name: 'Priya Sharma',
      username: 'priya',
      xp: 720,
      rank: 'Contributor Level 2',
      challengesCompleted: 2,
      position: 2,
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
    const AchievementModel(
      id: 2,
      title: 'XP Vanguard',
      badgeIcon: '💎',
      description: 'Earned over 500 total community experience points',
      xpReward: 150,
    ),
  ];

  setUp(() {
    mockRepo = MockGamificationRepository();
    when(() => mockRepo.getArenaChallenges()).thenAnswer((_) async => sampleChallenges);
    when(() => mockRepo.getLeaderboard(limit: any(named: 'limit'))).thenAnswer((_) async => sampleLeaderboard);
    when(() => mockRepo.getAchievements()).thenAnswer((_) async => sampleAchievements);
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        gamificationRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        home: WeeklyArenaScreen(),
      ),
    );
  }

  testWidgets('renders WeeklyArenaScreen with hero banner and challenges', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Weekly Arena'), findsWidgets);
    expect(find.text('Weekly Arena Active'), findsOneWidget);
    expect(find.text('Fix a project issue'), findsOneWidget);
    expect(find.text('Improve existing code'), findsOneWidget);
    expect(find.text('Accept Challenge'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
  });

  testWidgets('switches to Leaderboard tab and renders top ranked peers', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Leaderboard Tab
    final leaderboardTab = find.text('Leaderboard');
    expect(leaderboardTab, findsOneWidget);
    await tester.tap(leaderboardTab);
    await tester.pumpAndSettle();

    expect(find.text('Top Contributors'), findsOneWidget);
    expect(find.text('Aryan Patel'), findsOneWidget);
    expect(find.text('850 XP'), findsOneWidget);
    expect(find.text('Priya Sharma'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
  });

  testWidgets('switches to Badges tab and renders unlocked badges', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Badges Tab
    final badgesTab = find.text('Badges');
    expect(badgesTab, findsOneWidget);
    await tester.tap(badgesTab);
    await tester.pumpAndSettle();

    expect(find.text('My Badges & Achievements'), findsOneWidget);
    expect(find.text('Gladiator'), findsOneWidget);
    expect(find.text('XP Vanguard'), findsOneWidget);
    expect(find.text('+75'), findsOneWidget);
    expect(find.text('+150'), findsOneWidget);
  });
}
