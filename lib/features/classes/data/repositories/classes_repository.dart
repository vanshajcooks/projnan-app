import '../../../../core/network/api_client.dart';
import '../../../../core/storage/offline_cache_service.dart';
import '../models/class_model.dart';
import '../models/class_roster_model.dart';
import '../models/team_model.dart';

abstract class IClassesRepository {
  Future<List<ClassModel>> getUserClasses();
  Future<ClassModel> joinClass(String code);
  Future<ClassModel> createClass(String name, String description);
  Future<List<TeamModel>> getUserTeams();
  Future<TeamModel> createTeam(String name, int classId);
  Future<ClassRosterDetailModel> getClassRoster(int classId);
  Future<bool> removeStudentFromClass(int classId, int studentId);
}

class ClassesRepository implements IClassesRepository {
  final ApiClient apiClient;
  final IOfflineCacheService? cacheService;

  ClassesRepository({required this.apiClient, this.cacheService});

  @override
  Future<List<ClassModel>> getUserClasses() async {
    try {
      final response = await apiClient.get('/classes');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        final classes = list.map((item) => ClassModel.fromJson(item as Map<String, dynamic>)).toList();
        if (cacheService != null) {
          final jsonList = classes.map((c) => c.toJson()).toList();
          await cacheService!.cacheJsonList('cached_user_classes', jsonList);
        }
        return classes;
      }
    } catch (_) {
      if (cacheService != null) {
        final cached = await cacheService!.getCachedJsonList('cached_user_classes');
        if (cached != null && cached.isNotEmpty) {
          return cached.map((item) => ClassModel.fromJson(item)).toList();
        }
      }
      return [];
    }
    return [];
  }

  @override
  Future<ClassModel> joinClass(String code) async {
    final response = await apiClient.post(
      '/classes/join',
      data: {'code': code.trim().toUpperCase()},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ClassModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to join class');
  }

  @override
  Future<ClassModel> createClass(String name, String description) async {
    final response = await apiClient.post(
      '/classes',
      data: {
        'name': name.trim(),
        'description': description.trim(),
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ClassModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to create class');
  }

  @override
  Future<List<TeamModel>> getUserTeams() async {
    final response = await apiClient.get('/teams');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => TeamModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<TeamModel> createTeam(String name, int classId) async {
    final response = await apiClient.post(
      '/teams',
      data: {
        'name': name.trim(),
        'classId': classId,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return TeamModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data?['message'] ?? 'Failed to create team');
  }

  @override
  Future<ClassRosterDetailModel> getClassRoster(int classId) async {
    final response = await apiClient.get('/classes/$classId');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ClassRosterDetailModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Class not found');
  }

  @override
  Future<bool> removeStudentFromClass(int classId, int studentId) async {
    final response = await apiClient.delete('/classes/$classId/students/$studentId');
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return true;
    }
    return false;
  }
}
