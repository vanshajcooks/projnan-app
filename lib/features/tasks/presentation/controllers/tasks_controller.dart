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
  final String selectedPriority; // 'All', 'Urgent', 'High', 'Medium', 'Low'
  final String selectedTaskType; // 'All', 'Weekly', 'Milestone', 'Quick'
  final String searchQuery;
  final bool showOnlyMyTasks;

  const TasksState({
    this.isLoading = false,
    this.tasks = const [],
    this.errorMessage,
    this.selectedFilter = 'All',
    this.selectedPriority = 'All',
    this.selectedTaskType = 'All',
    this.searchQuery = '',
    this.showOnlyMyTasks = true,
  });

  List<TaskModel> get filteredTasks {
    return tasks.where((t) {
      // Status filter
      if (selectedFilter != 'All') {
        if (selectedFilter == 'Planned' && t.status.toLowerCase() != 'planned') return false;
        if (selectedFilter == 'In Progress' && t.status.toLowerCase() != 'in progress') return false;
        if (selectedFilter == 'Verification Pending' && t.status.toLowerCase() != 'verification pending') return false;
        if (selectedFilter == 'Completed' && t.status.toLowerCase() != 'completed') return false;
      }
      // Priority filter
      if (selectedPriority != 'All') {
        if (t.priority.toLowerCase() != selectedPriority.toLowerCase()) return false;
      }
      // Task Type filter
      if (selectedTaskType != 'All') {
        if (t.taskType.toLowerCase() != selectedTaskType.toLowerCase()) return false;
      }
      // Keyword search
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchDesc = t.description?.toLowerCase().contains(query) ?? false;
        final matchProject = t.projectName?.toLowerCase().contains(query) ?? false;
        if (!matchTitle && !matchDesc && !matchProject) return false;
      }
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
    String? selectedPriority,
    String? selectedTaskType,
    String? searchQuery,
    bool? showOnlyMyTasks,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedTaskType: selectedTaskType ?? this.selectedTaskType,
      searchQuery: searchQuery ?? this.searchQuery,
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(selectedPriority: priority);
  }

  void setTaskTypeFilter(String type) {
    state = state.copyWith(selectedTaskType: type);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedFilter: 'All',
      selectedPriority: 'All',
      selectedTaskType: 'All',
    );
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
