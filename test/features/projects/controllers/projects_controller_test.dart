import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/projects/data/models/project_model.dart';
import 'package:probon_app/features/projects/data/repositories/projects_repository.dart';
import 'package:probon_app/features/projects/presentation/controllers/projects_controller.dart';

class MockProjectsRepository extends Mock implements IProjectsRepository {}

void main() {
  late MockProjectsRepository mockRepository;
  late ProviderContainer container;

  const sampleProjects = [
    ProjectModel(id: 1, name: 'Active Project 1', status: 'Active', progress: 40),
    ProjectModel(id: 2, name: 'Done Project 2', status: 'Completed', progress: 100),
  ];

  setUp(() {
    mockRepository = MockProjectsRepository();
    container = ProviderContainer(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('ProjectsNotifier Tests', () {
    test('initial state has loading true', () {
      final state = container.read(projectsNotifierProvider);
      expect(state.isLoading, true);
      expect(state.projects, isEmpty);
    });

    test('fetchProjects populates projects list on success', () async {
      when(() => mockRepository.getUserProjects()).thenAnswer((_) async => sampleProjects);

      await container.read(projectsNotifierProvider.notifier).fetchProjects();
      final state = container.read(projectsNotifierProvider);

      expect(state.isLoading, false);
      expect(state.projects.length, 2);
      expect(state.filteredProjects.length, 2);
    });

    test('filtering projects by status returns correct subsets', () async {
      when(() => mockRepository.getUserProjects()).thenAnswer((_) async => sampleProjects);
      await container.read(projectsNotifierProvider.notifier).fetchProjects();

      // Filter Active
      container.read(projectsNotifierProvider.notifier).setFilter('Active');
      expect(container.read(projectsNotifierProvider).filteredProjects.length, 1);
      expect(container.read(projectsNotifierProvider).filteredProjects.first.name, 'Active Project 1');

      // Filter Completed
      container.read(projectsNotifierProvider.notifier).setFilter('Completed');
      expect(container.read(projectsNotifierProvider).filteredProjects.length, 1);
      expect(container.read(projectsNotifierProvider).filteredProjects.first.name, 'Done Project 2');
    });
  });
}
