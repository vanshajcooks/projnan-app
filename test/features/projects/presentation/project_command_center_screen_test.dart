import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/projects/data/models/feedback_model.dart';
import 'package:probon_app/features/projects/data/models/github_activity_model.dart';
import 'package:probon_app/features/projects/data/models/milestone_model.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';
import 'package:probon_app/features/projects/presentation/screens/project_command_center_screen.dart';

class MockProjectsRepository extends Mock implements IProjectsRepository {}

void main() {
  late MockProjectsRepository mockRepository;

  final sampleProject = ProjectModel(
    id: 107,
    name: 'Cloud Monitor Platform',
    description: 'High performance monitoring daemon',
    status: 'Active',
    progress: 75,
    repository: const {
      'repo_name': 'cloudninjas/monitor-daemon',
      'url': 'https://github.com/cloudninjas/monitor-daemon',
      'default_branch': 'main',
      'stars': 12,
      'forks': 3,
      'open_issues': 1,
    },
    members: const [
      {'id': 1, 'name': 'Aryan Thakkar', 'role': 'Lead Developer'},
    ],
    milestones: const [
      MilestoneModel(
        id: 1,
        projectId: 107,
        title: 'Alpha Architecture Release',
        description: 'Complete eBPF tracer modules',
        status: 'completed',
        taskCount: 6,
        completedTaskCount: 6,
      ),
      MilestoneModel(
        id: 2,
        projectId: 107,
        title: 'Beta Integration & Testing',
        description: 'End to end pipeline tests',
        status: 'pending',
        taskCount: 8,
        completedTaskCount: 4,
      ),
    ],
    taskStats: const {
      'total': 14,
      'completed': 10,
      'in_progress': 3,
      'review': 1,
    },
  );

  final sampleCommits = [
    const GitHubActivityModel(
      id: 1,
      projectId: 107,
      title: 'feat: add ring buffer collector daemon',
      activityType: 'commit',
      authorUsername: 'Aryan Thakkar',
      commitHash: 'abc123456789',
      timestamp: '2026-11-02T10:00:00Z',
      url: 'https://github.com/cloudninjas/monitor-daemon/commit/abc',
    ),
  ];

  final sampleFeedbacks = [
    const FeedbackModel(
      id: 501,
      projectId: 107,
      authorId: 10,
      authorName: 'Dr. Elena Vance',
      authorRole: 'Instructor',
      rating: 5,
      comment: 'Superb architecture and test coverage across modules.',
      createdAt: '2026-11-02T12:00:00Z',
    ),
  ];

  setUp(() {
    mockRepository = MockProjectsRepository();
    when(() => mockRepository.getProjectById(107)).thenAnswer((_) async => sampleProject);
    when(() => mockRepository.getCommits(107)).thenAnswer((_) async => sampleCommits);
    when(() => mockRepository.getPullRequests(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
    when(() => mockRepository.getIssues(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
    when(() => mockRepository.getProjectFeedback(107)).thenAnswer((_) async => sampleFeedbacks);
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: ProjectCommandCenterScreen(projectId: 107),
      ),
    );
  }

  testWidgets('renders ProjectCommandCenterScreen with project title and milestones', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Project Name & Milestones displayed
    expect(find.text('Cloud Monitor Platform'), findsWidgets);
    expect(find.text('Alpha Architecture Release'), findsOneWidget);
    expect(find.text('Beta Integration & Testing'), findsOneWidget);
    expect(find.text('Add Milestone'), findsOneWidget);
  });

  testWidgets('switches to GitHub Hub tab and displays repo details and commits', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap the GitHub Hub Tab
    final githubTab = find.text('GitHub Hub');
    expect(githubTab, findsOneWidget);
    await tester.tap(githubTab);
    await tester.pumpAndSettle();

    // Verify Repository Name and Commit message
    expect(find.text('cloudninjas/monitor-daemon'), findsOneWidget);
    expect(find.text('feat: add ring buffer collector daemon'), findsOneWidget);
    expect(find.textContaining('Aryan Thakkar'), findsWidgets);
  });

  testWidgets('switches to Evaluations tab and displays evaluations and rating', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap the Evaluations Tab
    final evaluationsTab = find.text('Evaluations');
    expect(evaluationsTab, findsOneWidget);
    await tester.tap(evaluationsTab);
    await tester.pumpAndSettle();

    // Verify Reviewer, comment, and Write Review button
    expect(find.text('Dr. Elena Vance'), findsOneWidget);
    expect(find.text('Superb architecture and test coverage across modules.'), findsOneWidget);
    expect(find.text('Write Review'), findsOneWidget);
  });
}
