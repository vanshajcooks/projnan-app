import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feedback_model.dart';
import '../../data/models/github_activity_model.dart';
import '../../data/models/project_model.dart';
import 'projects_controller.dart';

class ProjectDetailState {
  final bool isLoading;
  final bool isSyncing;
  final ProjectModel? project;
  final List<GitHubActivityModel> commits;
  final List<GitHubActivityModel> pullRequests;
  final List<GitHubActivityModel> issues;
  final List<FeedbackModel> feedbacks;
  final String? errorMessage;

  const ProjectDetailState({
    this.isLoading = true,
    this.isSyncing = false,
    this.project,
    this.commits = const [],
    this.pullRequests = const [],
    this.issues = const [],
    this.feedbacks = const [],
    this.errorMessage,
  });

  ProjectDetailState copyWith({
    bool? isLoading,
    bool? isSyncing,
    ProjectModel? project,
    List<GitHubActivityModel>? commits,
    List<GitHubActivityModel>? pullRequests,
    List<GitHubActivityModel>? issues,
    List<FeedbackModel>? feedbacks,
    String? errorMessage,
  }) {
    return ProjectDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      project: project ?? this.project,
      commits: commits ?? this.commits,
      pullRequests: pullRequests ?? this.pullRequests,
      issues: issues ?? this.issues,
      feedbacks: feedbacks ?? this.feedbacks,
      errorMessage: errorMessage,
    );
  }
}

class ProjectDetailNotifier extends Notifier<ProjectDetailState> {
  final int projectId;

  ProjectDetailNotifier(this.projectId);

  @override
  ProjectDetailState build() {
    Future.microtask(() => loadDetails());
    return const ProjectDetailState(isLoading: true);
  }

  Future<void> loadDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(projectsRepositoryProvider);
      final results = await Future.wait([
        repo.getProjectById(projectId),
        repo.getCommits(projectId),
        repo.getPullRequests(projectId),
        repo.getIssues(projectId),
        repo.getProjectFeedback(projectId),
      ]);

      state = state.copyWith(
        isLoading: false,
        project: results[0] as ProjectModel,
        commits: results[1] as List<GitHubActivityModel>,
        pullRequests: results[2] as List<GitHubActivityModel>,
        issues: results[3] as List<GitHubActivityModel>,
        feedbacks: results[4] as List<FeedbackModel>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> syncGithub() async {
    state = state.copyWith(isSyncing: true);
    try {
      final repo = ref.read(projectsRepositoryProvider);
      await repo.syncRepository(projectId);
      // Reload activities & project
      final commits = await repo.getCommits(projectId);
      final pulls = await repo.getPullRequests(projectId);
      final issues = await repo.getIssues(projectId);
      final project = await repo.getProjectById(projectId);

      state = state.copyWith(
        isSyncing: false,
        project: project,
        commits: commits,
        pullRequests: pulls,
        issues: issues,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSyncing: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> connectGithub(String repoUrl, {String? defaultBranch, String? token}) async {
    try {
      final repo = ref.read(projectsRepositoryProvider);
      await repo.connectRepository(projectId, repoUrl, defaultBranch: defaultBranch, token: token);
      await loadDetails();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addMilestone(String title, String description, int xpReward) async {
    try {
      final repo = ref.read(projectsRepositoryProvider);
      await repo.createMilestone(projectId, title, description, xpReward: xpReward);
      await loadDetails();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> submitFeedback(String comment, int rating, String type) async {
    try {
      final repo = ref.read(projectsRepositoryProvider);
      await repo.createFeedback(projectId, comment, rating: rating, type: type);
      final feedbacks = await repo.getProjectFeedback(projectId);
      state = state.copyWith(feedbacks: feedbacks);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final projectDetailNotifierProvider =
    NotifierProvider.autoDispose.family<ProjectDetailNotifier, ProjectDetailState, int>(
  (arg) => ProjectDetailNotifier(arg),
);
