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
    test('initial state has loading true and showOnlyMyTasks true', () {
      final state = container.read(tasksNotifierProvider);
      expect(state.isLoading, true);
      expect(state.tasks, isEmpty);
      expect(state.showOnlyMyTasks, true);
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

    test('toggleScope toggles scope and fetches all tasks', () async {
      when(() => mockRepository.getAllTasks()).thenAnswer((_) async => sampleTasks);

      await container.read(tasksNotifierProvider.notifier).toggleScope(false);
      final state = container.read(tasksNotifierProvider);

      expect(state.showOnlyMyTasks, false);
      verify(() => mockRepository.getAllTasks()).called(1);
    });

    test('submitEvidence updates task status and completion evidence in memory', () async {
      when(() => mockRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);
      await container.read(tasksNotifierProvider.notifier).fetchTasks();

      const evidenceTask = TaskModel(
        id: 2,
        projectId: 10,
        title: 'Task 2',
        status: 'Verification Pending',
        completionEvidence: 'PR #42',
      );
      when(() => mockRepository.submitEvidence(2, 'PR #42')).thenAnswer((_) async => evidenceTask);

      final success = await container.read(tasksNotifierProvider.notifier).submitEvidence(2, 'PR #42');

      expect(success, true);
      final task2 = container.read(tasksNotifierProvider).tasks.firstWhere((t) => t.id == 2);
      expect(task2.status, 'Verification Pending');
      expect(task2.completionEvidence, 'PR #42');
    });

    test('verifyTask updates task status to Completed when approved', () async {
      when(() => mockRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);
      await container.read(tasksNotifierProvider.notifier).fetchTasks();

      const verifiedTask = TaskModel(
        id: 2,
        projectId: 10,
        title: 'Task 2',
        status: 'Completed',
        verificationStatus: 'verified',
      );
      when(() => mockRepository.verifyTask(2, approved: true, feedbackNote: 'Great tests'))
          .thenAnswer((_) async => verifiedTask);

      final success = await container.read(tasksNotifierProvider.notifier).verifyTask(
            2,
            approved: true,
            feedbackNote: 'Great tests',
          );

      expect(success, true);
      final task2 = container.read(tasksNotifierProvider).tasks.firstWhere((t) => t.id == 2);
      expect(task2.status, 'Completed');
      expect(task2.isVerified, true);
    });

    test('deleteTask removes task from state in memory', () async {
      when(() => mockRepository.getMyTasks()).thenAnswer((_) async => sampleTasks);
      await container.read(tasksNotifierProvider.notifier).fetchTasks();

      when(() => mockRepository.deleteTask(1)).thenAnswer((_) async => true);

      final success = await container.read(tasksNotifierProvider.notifier).deleteTask(1);

      expect(success, true);
      final tasks = container.read(tasksNotifierProvider).tasks;
      expect(tasks.length, 2);
      expect(tasks.any((t) => t.id == 1), false);
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
