import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

final tasksRepositoryProvider = Provider<ITasksRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(offlineCacheServiceProvider);
  return TasksRepository(apiClient: client, cacheService: cache);
});

class TasksState {
  final bool isLoading;
  final List<TaskModel> tasks;
  final String? errorMessage;
  final String selectedFilter; // 'All', 'Planned', 'In Progress', 'Verification Pending', 'Completed'
  final bool showOnlyMyTasks;

  const TasksState({
    this.isLoading = false,
    this.tasks = const [],
    this.errorMessage,
    this.selectedFilter = 'All',
    this.showOnlyMyTasks = true,
  });

  List<TaskModel> get filteredTasks {
    if (selectedFilter == 'All') return tasks;
    return tasks.where((t) {
      if (selectedFilter == 'Planned') return t.status.toLowerCase() == 'planned';
      if (selectedFilter == 'In Progress') return t.status.toLowerCase() == 'in progress';
      if (selectedFilter == 'Verification Pending') return t.status.toLowerCase() == 'verification pending';
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
    bool? showOnlyMyTasks,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      showOnlyMyTasks: showOnlyMyTasks ?? this.showOnlyMyTasks,
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
      final list = state.showOnlyMyTasks
          ? await repository.getMyTasks()
          : await repository.getAllTasks();
      state = state.copyWith(isLoading: false, tasks: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> toggleScope(bool onlyMine) async {
    if (state.showOnlyMyTasks == onlyMine) return;
    state = state.copyWith(showOnlyMyTasks: onlyMine);
    await fetchTasks();
  }

  Future<bool> updateStatus(int taskId, String newStatus) async {
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final updated = await repository.updateTaskStatus(taskId, newStatus);

      final updatedList = state.tasks.map((t) => t.id == taskId ? updated : t).toList();
      state = state.copyWith(tasks: updatedList);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitEvidence(int taskId, String evidence) async {
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final updated = await repository.submitEvidence(taskId, evidence);

      final updatedList = state.tasks.map((t) => t.id == taskId ? updated : t).toList();
      state = state.copyWith(tasks: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyTask(int taskId, {required bool approved, String? feedbackNote}) async {
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final updated = await repository.verifyTask(
        taskId,
        approved: approved,
        feedbackNote: feedbackNote,
      );

      final updatedList = state.tasks.map((t) => t.id == taskId ? updated : t).toList();
      state = state.copyWith(tasks: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final success = await repository.deleteTask(taskId);
      if (success) {
        state = state.copyWith(
          tasks: state.tasks.where((t) => t.id == taskId ? false : true).toList(),
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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
