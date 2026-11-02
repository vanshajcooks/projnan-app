import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/projects/data/models/feedback_model.dart';
import 'package:probon_app/features/projects/data/models/github_activity_model.dart';
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
    name: 'Quantum Simulation Engine',
    description: 'Quantum state computation suite.',
    status: 'active',
    progress: 50,
    tags: ['Quantum', 'Flutter'],
    goals: ['Initialize qubit state', 'Run Bell test'],
    milestones: [
      MilestoneModel(
        id: 10,
        projectId: 1,
        title: 'Qubit State Simulator',
        description: 'Matrix multiplication pipeline',
        xpReward: 250,
        status: 'pending',
      ),
    ],
  );

  const updatedMilestone = MilestoneModel(
    id: 10,
    projectId: 1,
    title: 'Qubit State Simulator',
    description: 'Matrix multiplication pipeline',
    xpReward: 250,
    status: 'completed',
  );

  setUp(() {
    mockProjectsRepository = MockProjectsRepository();
    when(() => mockProjectsRepository.getProjectById(1)).thenAnswer((_) async => testProject);
    when(() => mockProjectsRepository.getCommits(1)).thenAnswer((_) async => []);
    when(() => mockProjectsRepository.getPullRequests(1)).thenAnswer((_) async => <GitHubActivityModel>[]);
    when(() => mockProjectsRepository.getIssues(1)).thenAnswer((_) async => <GitHubActivityModel>[]);
    when(() => mockProjectsRepository.getProjectFeedback(1)).thenAnswer((_) async => <FeedbackModel>[]);
    when(() => mockProjectsRepository.getProjectAnalytics(1)).thenAnswer((_) async => const ProjectAnalyticsModel());
    when(() => mockProjectsRepository.updateMilestone(1, 10, status: 'completed'))
        .thenAnswer((_) async => updatedMilestone);
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

  testWidgets('ProjectCommandCenterScreen allows marking milestone as complete and awards XP', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify milestone is visible
    expect(find.text('Qubit State Simulator'), findsOneWidget);
    expect(find.text('+250 XP'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);

    // Tap Complete toggle icon
    await tester.tap(find.byIcon(LucideIcons.circleDashed));
    await tester.pumpAndSettle();

    verify(() => mockProjectsRepository.updateMilestone(1, 10, status: 'completed')).called(1);
    expect(find.textContaining('+250 XP awarded to team!'), findsOneWidget);
  });
}
