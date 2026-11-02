import '../../../../core/network/api_client.dart';
import '../models/project_model.dart';

abstract class IProjectsRepository {
  Future<List<ProjectModel>> getUserProjects();
  Future<ProjectModel> getProjectById(int projectId);
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
}
