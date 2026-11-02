import '../../../../core/network/api_client.dart';
import '../models/task_model.dart';

abstract class ITasksRepository {
  Future<List<TaskModel>> getMyTasks();
  Future<List<TaskModel>> getAllTasks({String? status, String? priority, int? projectId});
  Future<List<TaskModel>> getProjectTasks(int projectId);
  Future<TaskModel> updateTaskStatus(int taskId, String newStatus);
  Future<TaskModel> submitEvidence(int taskId, String evidence);
  Future<TaskModel> verifyTask(int taskId, {required bool approved, String? feedbackNote});
  Future<bool> deleteTask(int taskId);
  Future<TaskModel> createTask({
    required int projectId,
    required String title,
    String? description,
    String priority = 'medium',
    String taskType = 'weekly',
    int xpValue = 50,
  });
}

class TasksRepository implements ITasksRepository {
  final ApiClient apiClient;

  TasksRepository({required this.apiClient});

  @override
  Future<List<TaskModel>> getMyTasks() async {
    try {
      final response = await apiClient.get('/tasks/my');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      try {
        final fallback = await apiClient.get('/tasks');
        final data = fallback.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
      return [];
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks({String? status, String? priority, int? projectId}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (projectId != null) queryParams['projectId'] = projectId;

    final response = await apiClient.get('/tasks', queryParameters: queryParams.isEmpty ? null : queryParams);
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<TaskModel>> getProjectTasks(int projectId) async {
    return getAllTasks(projectId: projectId);
  }

  @override
  Future<TaskModel> updateTaskStatus(int taskId, String newStatus) async {
    final response = await apiClient.put(
      '/tasks/$taskId',
      data: {'status': newStatus},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update task status');
  }

  @override
  Future<TaskModel> submitEvidence(int taskId, String evidence) async {
    final response = await apiClient.post(
      '/tasks/$taskId/evidence',
      data: {'evidence': evidence.trim()},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to submit evidence');
  }

  @override
  Future<TaskModel> verifyTask(int taskId, {required bool approved, String? feedbackNote}) async {
    final payload = <String, dynamic>{
      'approved': approved,
    };
    if (feedbackNote != null && feedbackNote.trim().isNotEmpty) {
      payload['feedbackNote'] = feedbackNote.trim();
    }

    final response = await apiClient.post(
      '/tasks/$taskId/verify',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to verify task');
  }

  @override
  Future<bool> deleteTask(int taskId) async {
    final response = await apiClient.delete('/tasks/$taskId');
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return true;
    }
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<TaskModel> createTask({
    required int projectId,
    required String title,
    String? description,
    String priority = 'medium',
    String taskType = 'weekly',
    int xpValue = 50,
  }) async {
    final payload = <String, dynamic>{
      'projectId': projectId,
      'title': title.trim(),
      'priority': priority.toLowerCase(),
      'taskType': taskType.toLowerCase(),
      'xpValue': xpValue,
    };
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }

    final response = await apiClient.post(
      '/tasks',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to create task');
  }
}
