import '../../../../core/network/api_client.dart';
import '../../../../core/storage/offline_cache_service.dart';
import '../models/feedback_model.dart';
import '../models/github_activity_model.dart';
import '../models/milestone_model.dart';
import '../models/project_analytics_model.dart';
import '../models/project_model.dart';

abstract class IProjectsRepository {
  Future<List<ProjectModel>> getUserProjects();
  Future<List<ProjectModel>> searchProjects({String? query, String? status});
  Future<ProjectModel> getProjectById(int projectId);
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    int? teamId,
    int? classId,
    List<String>? tags,
    List<String>? goals,
  });
  Future<Map<String, dynamic>> connectRepository(int projectId, String repoUrl, {String? defaultBranch, String? token});
  Future<Map<String, dynamic>> syncRepository(int projectId);
  Future<List<GitHubActivityModel>> getCommits(int projectId, {int limit = 50});
  Future<List<GitHubActivityModel>> getPullRequests(int projectId, {int limit = 50});
  Future<List<GitHubActivityModel>> getIssues(int projectId, {int limit = 50});
  Future<List<FeedbackModel>> getProjectFeedback(int projectId);
  Future<FeedbackModel> createFeedback(int projectId, String comment, {int rating = 5, String type = 'teacher_review'});
  Future<MilestoneModel> createMilestone(int projectId, String title, String description, {int xpReward = 100, String? dueDate});
  Future<MilestoneModel> updateMilestone(int projectId, int milestoneId, {String? status, String? title, String? description});
  Future<ProjectModel> updateProject(int projectId, {String? name, String? description, String? status, List<String>? tags, List<String>? goals});
  Future<ProjectAnalyticsModel> getProjectAnalytics(int projectId);
}

class ProjectsRepository implements IProjectsRepository {
  final ApiClient apiClient;
  final IOfflineCacheService? cacheService;

  ProjectsRepository({required this.apiClient, this.cacheService});

  @override
  Future<List<ProjectModel>> getUserProjects() async {
    try {
      final response = await apiClient.get('/projects/my');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        final projs = list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
        if (cacheService != null) {
          final jsonList = projs.map((p) => p.toJson()).toList();
          await cacheService!.cacheJsonList('cached_user_projects', jsonList);
        }
        return projs;
      }
      return [];
    } catch (_) {
      // If /projects/my fails or empty, attempt /projects or offline cache
      try {
        final fallback = await apiClient.get('/projects');
        final data = fallback.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final list = data['data'] as List;
          final projs = list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
          if (cacheService != null) {
            final jsonList = projs.map((p) => p.toJson()).toList();
            await cacheService!.cacheJsonList('cached_user_projects', jsonList);
          }
          return projs;
        }
      } catch (_) {}

      // Fallback to offline cache
      if (cacheService != null) {
        final cached = await cacheService!.getCachedJsonList('cached_user_projects');
        if (cached != null && cached.isNotEmpty) {
          return cached.map((item) => ProjectModel.fromJson(item)).toList();
        }
      }
      return [];
    }
  }

  @override
  Future<List<ProjectModel>> searchProjects({String? query, String? status}) async {
    final params = <String, dynamic>{};
    if (query != null && query.trim().isNotEmpty) params['search'] = query.trim();
    if (status != null && status.isNotEmpty) params['status'] = status;

    try {
      final response = await apiClient.get('/projects', queryParameters: params.isEmpty ? null : params);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        return list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProjectModel> getProjectById(int projectId) async {
    final response = await apiClient.get('/projects/$projectId');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ProjectModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Project not found');
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    int? teamId,
    int? classId,
    List<String>? tags,
    List<String>? goals,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'description': description.trim(),
    };
    if (teamId != null) payload['teamId'] = teamId;
    if (classId != null) payload['classId'] = classId;
    if (tags != null && tags.isNotEmpty) payload['tags'] = tags;
    if (goals != null && goals.isNotEmpty) payload['goals'] = goals;

    final response = await apiClient.post(
      '/projects',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ProjectModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to create project');
  }

  @override
  Future<Map<String, dynamic>> connectRepository(int projectId, String repoUrl, {String? defaultBranch, String? token}) async {
    final response = await apiClient.post(
      '/github/$projectId/connect',
      data: {
        'repoUrl': repoUrl.trim(),
        'defaultBranch': defaultBranch?.trim() ?? 'main',
        if (token != null && token.trim().isNotEmpty) 'accessToken': token.trim(),
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data?['message'] ?? 'Failed to connect repository');
  }

  @override
  Future<Map<String, dynamic>> syncRepository(int projectId) async {
    final response = await apiClient.post('/github/$projectId/sync');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'success': true};
  }

  @override
  Future<List<GitHubActivityModel>> getCommits(int projectId, {int limit = 50}) async {
    final response = await apiClient.get('/github/$projectId/commits', queryParameters: {'limit': limit});
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => GitHubActivityModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<GitHubActivityModel>> getPullRequests(int projectId, {int limit = 50}) async {
    final response = await apiClient.get('/github/$projectId/pull-requests', queryParameters: {'limit': limit});
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => GitHubActivityModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<GitHubActivityModel>> getIssues(int projectId, {int limit = 50}) async {
    final response = await apiClient.get('/github/$projectId/issues', queryParameters: {'limit': limit});
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => GitHubActivityModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<FeedbackModel>> getProjectFeedback(int projectId) async {
    final response = await apiClient.get('/feedback/project/$projectId');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => FeedbackModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<FeedbackModel> createFeedback(int projectId, String comment, {int rating = 5, String type = 'teacher_review'}) async {
    final response = await apiClient.post(
      '/feedback',
      data: {
        'projectId': projectId,
        'comment': comment.trim(),
        'rating': rating,
        'type': type,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return FeedbackModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to submit feedback');
  }

  @override
  Future<MilestoneModel> createMilestone(int projectId, String title, String description, {int xpReward = 100, String? dueDate}) async {
    final payload = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'xpReward': xpReward,
    };
    if (dueDate != null) {
      payload['dueDate'] = dueDate;
    }
    final response = await apiClient.post(
      '/projects/$projectId/milestones',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return MilestoneModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to create milestone');
  }

  @override
  Future<MilestoneModel> updateMilestone(int projectId, int milestoneId, {String? status, String? title, String? description}) async {
    final payload = <String, dynamic>{};
    if (status != null) payload['status'] = status;
    if (title != null) payload['title'] = title.trim();
    if (description != null) payload['description'] = description.trim();

    final response = await apiClient.put(
      '/projects/$projectId/milestones/$milestoneId',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return MilestoneModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to update milestone');
  }

  @override
  Future<ProjectModel> updateProject(int projectId, {String? name, String? description, String? status, List<String>? tags, List<String>? goals}) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name.trim();
    if (description != null) payload['description'] = description.trim();
    if (status != null) payload['status'] = status;
    if (tags != null) payload['tags'] = tags;
    if (goals != null) payload['goals'] = goals;

    final response = await apiClient.put(
      '/projects/$projectId',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ProjectModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to update project');
  }

  @override
  Future<ProjectAnalyticsModel> getProjectAnalytics(int projectId) async {
    try {
      final response = await apiClient.get('/progress/analytics/$projectId');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return ProjectAnalyticsModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return const ProjectAnalyticsModel();
    } catch (_) {
      return const ProjectAnalyticsModel();
    }
  }
}
