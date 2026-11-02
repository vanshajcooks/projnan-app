import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/projects_repository.dart';

final projectsRepositoryProvider = Provider<IProjectsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProjectsRepository(apiClient: client);
});

class ProjectsState {
  final bool isLoading;
  final List<ProjectModel> projects;
  final String? errorMessage;
  final String selectedFilter; // 'All', 'Active', 'Completed'

  const ProjectsState({
    this.isLoading = false,
    this.projects = const [],
    this.errorMessage,
    this.selectedFilter = 'All',
  });

  List<ProjectModel> get filteredProjects {
    if (selectedFilter == 'All') return projects;
    return projects.where((p) {
      if (selectedFilter == 'Completed') return p.isCompleted;
      if (selectedFilter == 'Active') return !p.isCompleted;
      return true;
    }).toList();
  }

  ProjectsState copyWith({
    bool? isLoading,
    List<ProjectModel>? projects,
    String? errorMessage,
    String? selectedFilter,
  }) {
    return ProjectsState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class ProjectsNotifier extends Notifier<ProjectsState> {
  @override
  ProjectsState build() {
    return const ProjectsState(isLoading: true);
  }

  Future<void> fetchProjects() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(projectsRepositoryProvider);
      final list = await repository.getUserProjects();
      state = state.copyWith(isLoading: false, projects: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<bool> createProject({
    required String name,
    required String description,
    int? teamId,
    int? classId,
    List<String>? tags,
    List<String>? goals,
  }) async {
    try {
      final repository = ref.read(projectsRepositoryProvider);
      await repository.createProject(
        name: name,
        description: description,
        teamId: teamId,
        classId: classId,
        tags: tags,
        goals: goals,
      );
      await fetchProjects();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final projectsNotifierProvider = NotifierProvider<ProjectsNotifier, ProjectsState>(() {
  return ProjectsNotifier();
});
