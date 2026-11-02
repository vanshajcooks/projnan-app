import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

final tasksRepositoryProvider = Provider<ITasksRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TasksRepository(apiClient: client);
});

class TasksState {
  final bool isLoading;
  final List<TaskModel> tasks;
  final String? errorMessage;
  final String selectedFilter; // 'All', 'Planned', 'In Progress', 'Completed'

  const TasksState({
    this.isLoading = false,
    this.tasks = const [],
    this.errorMessage,
    this.selectedFilter = 'All',
  });

  List<TaskModel> get filteredTasks {
    if (selectedFilter == 'All') return tasks;
    return tasks.where((t) {
      if (selectedFilter == 'Planned') return t.status.toLowerCase() == 'planned';
      if (selectedFilter == 'In Progress') return t.status.toLowerCase() == 'in progress';
      if (selectedFilter == 'Completed') return t.status.toLowerCase() == 'completed';
      return true;
    }).toList();
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

  TasksState copyWith({
    bool? isLoading,
    List<TaskModel>? tasks,
    String? errorMessage,
    String? selectedFilter,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class TasksNotifier extends Notifier<TasksState> {
  @override
  TasksState build() {
    return const TasksState(isLoading: true);
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final list = await repository.getMyTasks();
      state = state.copyWith(isLoading: false, tasks: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<bool> updateStatus(int taskId, String newStatus) async {
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final updated = await repository.updateTaskStatus(taskId, newStatus);

      // Update in memory list
      final updatedList = state.tasks.map((t) => t.id == taskId ? updated : t).toList();
      state = state.copyWith(tasks: updatedList);
      return true;
    } catch (e) {
      // If server update fails, optimistically or show error
      return false;
    }
  }

  Future<bool> createTask({
    required int projectId,
    required String title,
    String? description,
    String priority = 'medium',
    String taskType = 'weekly',
    int xpValue = 50,
  }) async {
    try {
      final repository = ref.read(tasksRepositoryProvider);
      await repository.createTask(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority,
        taskType: taskType,
        xpValue: xpValue,
      );
      await fetchTasks();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final tasksNotifierProvider = NotifierProvider<TasksNotifier, TasksState>(() {
  return TasksNotifier();
});
