import '../../../../core/network/api_client.dart';
import '../models/class_model.dart';
import '../models/team_model.dart';

abstract class IClassesRepository {
  Future<List<ClassModel>> getUserClasses();
  Future<ClassModel> joinClass(String code);
  Future<ClassModel> createClass(String name, String description);
  Future<List<TeamModel>> getUserTeams();
  Future<TeamModel> createTeam(String name, int classId);
}

class ClassesRepository implements IClassesRepository {
  final ApiClient apiClient;

  ClassesRepository({required this.apiClient});

  @override
  Future<List<ClassModel>> getUserClasses() async {
    final response = await apiClient.get('/classes');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => ClassModel.fromJson(item as Map<String, dynamic>)).toList();
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
}
