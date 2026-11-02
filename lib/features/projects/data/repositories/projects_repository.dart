import '../../../../core/network/api_client.dart';
import '../models/project_model.dart';

abstract class IProjectsRepository {
  Future<List<ProjectModel>> getUserProjects();
  Future<ProjectModel> getProjectById(int projectId);
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    int? teamId,
    int? classId,
    List<String>? tags,
    List<String>? goals,
  });
}

class ProjectsRepository implements IProjectsRepository {
  final ApiClient apiClient;

  ProjectsRepository({required this.apiClient});

  @override
  Future<List<ProjectModel>> getUserProjects() async {
    try {
      final response = await apiClient.get('/projects/my');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        return list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      // If /projects/my fails or empty, attempt /projects
      try {
        final fallback = await apiClient.get('/projects');
        final data = fallback.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
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
}
