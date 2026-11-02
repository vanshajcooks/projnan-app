import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/tasks/data/models/task_model.dart';
import 'package:probon_app/features/tasks/data/repositories/tasks_repository.dart';
import 'package:probon_app/features/tasks/presentation/controllers/tasks_controller.dart';

class MockTasksRepository extends Mock implements ITasksRepository {}

void main() {
  late MockTasksRepository mockRepository;
  late ProviderContainer container;

  const sampleTasks = [
    TaskModel(id: 1, projectId: 10, title: 'Task 1', status: 'Planned'),
    TaskModel(id: 2, projectId: 10, title: 'Task 2', status: 'In Progress'),
    TaskModel(id: 3, projectId: 10, title: 'Task 3', status: 'Completed'),
  ];

  setUp(() {
    mockRepository = MockTasksRepository();
    container = ProviderContainer(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('TasksNotifier Tests', () {
    test('initial state has loading true', () {
      final state = container.read(tasksNotifierProvider);
      expect(state.isLoading, true);
      expect(state.tasks, isEmpty);
    });

    test('fetchTasks populates tasks list and computes counts', () async {
      when(() => mockRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);

      await container.read(tasksNotifierProvider.notifier).fetchTasks();
      final state = container.read(tasksNotifierProvider);

      expect(state.isLoading, false);
      expect(state.tasks.length, 3);
      expect(state.completedCount, 1);
      expect(state.pendingCount, 2);
    });

    test('filter by status updates filtered list', () async {
      when(() => mockRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);
      await container.read(tasksNotifierProvider.notifier).fetchTasks();

      container.read(tasksNotifierProvider.notifier).setFilter('Completed');
      final filtered = container.read(tasksNotifierProvider).filteredTasks;

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Task 3');
    });

    test('updateStatus updates task status in memory on success', () async {
      when(() => mockRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);
      await container.read(tasksNotifierProvider.notifier).fetchTasks();

      const updatedTask = TaskModel(id: 1, projectId: 10, title: 'Task 1', status: 'Completed');
      when(() => mockRepository.updateTaskStatus(1, 'Completed')).thenAnswer((_) async => updatedTask);

      final success = await container.read(tasksNotifierProvider.notifier).updateStatus(1, 'Completed');

      expect(success, true);
      final task1 = container.read(tasksNotifierProvider).tasks.firstWhere((t) => t.id == 1);
      expect(task1.status, 'Completed');
    });
  });
}
