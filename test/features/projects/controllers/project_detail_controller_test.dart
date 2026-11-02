import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/projects/data/models/feedback_model.dart';
import 'package:probon_app/features/projects/data/models/github_activity_model.dart';
import 'package:probon_app/features/projects/data/models/milestone_model.dart';
import 'package:probon_app/features/projects/data/models/project_analytics_model.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/project_detail_controller.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';

class MockProjectsRepository extends Mock implements IProjectsRepository {}

void main() {
  late MockProjectsRepository mockRepository;
  late ProviderContainer container;

  final sampleProject = ProjectModel(
    id: 107,
    name: 'Cloud Monitor Platform',
    status: 'Active',
    progress: 80,
    repository: const {
      'url': 'https://github.com/cloudninjas/monitor-daemon',
      'stars': 15,
      'forks': 4,
      'open_issues': 1,
    },
    milestones: const [
      MilestoneModel(
        id: 1,
        projectId: 107,
        title: 'Core Telemetry Engine',
        description: 'Implement eBPF tracing hook',
        status: 'completed',
        taskCount: 6,
        completedTaskCount: 6,
      ),
    ],
  );

  final sampleCommits = [
    const GitHubActivityModel(
      id: 1,
      projectId: 107,
      title: 'feat: add ring buffer collector',
      activityType: 'commit',
      authorUsername: 'Aryan Thakkar',
      timestamp: '2026-11-02T10:00:00Z',
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
      comment: 'Superb architecture',
      createdAt: '2026-11-02T12:00:00Z',
    ),
  ];

  setUp(() {
    mockRepository = MockProjectsRepository();
    when(() => mockRepository.getProjectAnalytics(any())).thenAnswer((_) async => const ProjectAnalyticsModel());
    container = ProviderContainer(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('ProjectDetailNotifier Tests', () {
    test('loadDetails fetches project, commits, PRs, issues and feedback', () async {
      when(() => mockRepository.getProjectById(107)).thenAnswer((_) async => sampleProject);
      when(() => mockRepository.getCommits(107)).thenAnswer((_) async => sampleCommits);
      when(() => mockRepository.getPullRequests(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getIssues(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getProjectFeedback(107)).thenAnswer((_) async => sampleFeedbacks);

      final notifier = container.read(projectDetailNotifierProvider(107).notifier);
      await notifier.loadDetails();

      final state = container.read(projectDetailNotifierProvider(107));
      expect(state.isLoading, false);
      expect(state.project?.name, 'Cloud Monitor Platform');
      expect(state.commits.length, 1);
      expect(state.commits.first.title, 'feat: add ring buffer collector');
      expect(state.feedbacks.length, 1);
      expect(state.feedbacks.first.rating, 5);
    });

    test('syncGithub triggers sync and refreshes activity data', () async {
      when(() => mockRepository.getProjectById(107)).thenAnswer((_) async => sampleProject);
      when(() => mockRepository.getCommits(107)).thenAnswer((_) async => sampleCommits);
      when(() => mockRepository.getPullRequests(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getIssues(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getProjectFeedback(107)).thenAnswer((_) async => sampleFeedbacks);
      when(() => mockRepository.syncRepository(107)).thenAnswer((_) async => {'success': true});

      final notifier = container.read(projectDetailNotifierProvider(107).notifier);
      final success = await notifier.syncGithub();

      expect(success, true);
      verify(() => mockRepository.syncRepository(107)).called(1);
    });

    test('connectGithub sends url and reloads details', () async {
      when(() => mockRepository.getProjectById(107)).thenAnswer((_) async => sampleProject);
      when(() => mockRepository.getCommits(107)).thenAnswer((_) async => sampleCommits);
      when(() => mockRepository.getPullRequests(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getIssues(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getProjectFeedback(107)).thenAnswer((_) async => sampleFeedbacks);
      when(() => mockRepository.connectRepository(
            107,
            'https://github.com/cloudninjas/monitor-daemon',
            defaultBranch: any(named: 'defaultBranch'),
            token: any(named: 'token'),
          )).thenAnswer((_) async => {'success': true});

      final notifier = container.read(projectDetailNotifierProvider(107).notifier);
      final success = await notifier.connectGithub(
        'https://github.com/cloudninjas/monitor-daemon',
        defaultBranch: 'main',
      );

      expect(success, true);
      verify(() => mockRepository.connectRepository(
            107,
            'https://github.com/cloudninjas/monitor-daemon',
            defaultBranch: 'main',
            token: null,
          )).called(1);
    });

    test('addMilestone creates milestone and reloads details', () async {
      when(() => mockRepository.getProjectById(107)).thenAnswer((_) async => sampleProject);
      when(() => mockRepository.getCommits(107)).thenAnswer((_) async => sampleCommits);
      when(() => mockRepository.getPullRequests(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getIssues(107)).thenAnswer((_) async => <GitHubActivityModel>[]);
      when(() => mockRepository.getProjectFeedback(107)).thenAnswer((_) async => sampleFeedbacks);
      when(() => mockRepository.createMilestone(
            107,
            'Sprint 2 Release',
            'Full collector API',
            xpReward: any(named: 'xpReward'),
          )).thenAnswer((_) async => const MilestoneModel(
            id: 2,
            projectId: 107,
            title: 'Sprint 2 Release',
            description: 'Full collector API',
          ));

      final notifier = container.read(projectDetailNotifierProvider(107).notifier);
      final success = await notifier.addMilestone('Sprint 2 Release', 'Full collector API', 100);

      expect(success, true);
      verify(() => mockRepository.createMilestone(
            107,
            'Sprint 2 Release',
            'Full collector API',
            xpReward: 100,
          )).called(1);
    });

    test('submitFeedback creates feedback and reloads feedback list', () async {
      when(() => mockRepository.getProjectFeedback(107)).thenAnswer((_) async => sampleFeedbacks);
      when(() => mockRepository.createFeedback(
            107,
            'Great progress!',
            rating: 4,
            type: 'peer',
          )).thenAnswer((_) async => sampleFeedbacks.first);

      final notifier = container.read(projectDetailNotifierProvider(107).notifier);
      final success = await notifier.submitFeedback('Great progress!', 4, 'peer');

      expect(success, true);
      verify(() => mockRepository.createFeedback(
            107,
            'Great progress!',
            rating: 4,
            type: 'peer',
          )).called(1);
    });
  });
}
