import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/projects/data/models/feedback_model.dart';
import 'package:probon_app/features/projects/data/models/milestone_model.dart';
import 'package:probon_app/features/projects/data/models/project_analytics_model.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/projects/presentation/screens/project_command_center_screen.dart';

class MockProjectsRepository extends Mock implements IProjectsRepository {}

void main() {
  late MockProjectsRepository mockProjectsRepository;

  const testProject = ProjectModel(
    id: 1,
    name: 'Smart Campus IoT',
    description: 'IoT network sensors and telemetry.',
    status: 'active',
    progress: 75,
    tags: ['IoT', 'Flutter', 'Embedded'],
    goals: ['Build hardware', 'Deploy dashboard'],
    milestones: [
      MilestoneModel(id: 10, projectId: 1, title: 'Sensor Deployment', description: 'Deploy nodes', xpReward: 200, status: 'completed'),
    ],
  );

  const testAnalytics = ProjectAnalyticsModel(
    totalTasks: 8,
    completedTasks: 6,
    completionRate: 75,
    totalContributions: 24,
    totalXp: 1800,
    tasksByStatus: {
      'Planned': 1,
      'In Progress': 1,
      'Verification Pending': 0,
      'Completed': 6,
    },
    memberAnalytics: [
      MemberAnalyticsModel(
        userId: 1,
        name: 'Sarah Connor',
        username: 'sconnor',
        role: 'lead',
        contributionCount: 18,
        xpEarned: 1400,
        tasksCompleted: 4,
        percentage: 75,
      ),
      MemberAnalyticsModel(
        userId: 2,
        name: 'Kyle Reese',
        username: 'kreese',
        role: 'developer',
        contributionCount: 6,
        xpEarned: 400,
        tasksCompleted: 2,
        percentage: 25,
      ),
    ],
  );

  setUp(() {
    mockProjectsRepository = MockProjectsRepository();
    when(() => mockProjectsRepository.getProjectById(1)).thenAnswer((_) async => testProject);
    when(() => mockProjectsRepository.getCommits(1)).thenAnswer((_) async => []);
    when(() => mockProjectsRepository.getPullRequests(1)).thenAnswer((_) async => []);
    when(() => mockProjectsRepository.getIssues(1)).thenAnswer((_) async => []);
    when(() => mockProjectsRepository.getProjectFeedback(1)).thenAnswer((_) async => <FeedbackModel>[]);
    when(() => mockProjectsRepository.getProjectAnalytics(1)).thenAnswer((_) async => testAnalytics);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(mockProjectsRepository),
      ],
      child: const MaterialApp(
        home: ProjectCommandCenterScreen(projectId: 1),
      ),
    );
  }

  testWidgets('ProjectCommandCenterScreen renders Analytics tab with velocity and member share', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify TabBar includes Analytics
    expect(find.text('Analytics'), findsOneWidget);

    // Tap Analytics tab
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    // Verify Velocity & Completion Card
    expect(find.text('Project Velocity & Completion'), findsOneWidget);
    expect(find.text('75%'), findsAtLeastNWidgets(1));
    expect(find.text('6 of 8 Tasks Completed'), findsOneWidget);

    // Verify Status chips
    expect(find.text('Planned: 1'), findsOneWidget);
    expect(find.text('In Progress: 1'), findsOneWidget);
    expect(find.text('Completed: 6'), findsOneWidget);

    // Verify Activities count and XP
    expect(find.text('24'), findsOneWidget);
    expect(find.text('1800 XP'), findsOneWidget);

    // Verify Member Contribution Share
    expect(find.text('Member Contribution Share'), findsOneWidget);
    expect(find.text('Sarah Connor'), findsOneWidget);
    expect(find.text('75% Share'), findsOneWidget);
    expect(find.text('Kyle Reese'), findsOneWidget);
    expect(find.text('25% Share'), findsOneWidget);
  });
}
