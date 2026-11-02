import '../../../../core/network/api_client.dart';
import '../models/achievement_model.dart';
import '../models/arena_challenge_model.dart';
import '../models/leaderboard_user_model.dart';

abstract class IGamificationRepository {
  Future<List<ArenaChallengeModel>> getArenaChallenges();
  Future<bool> acceptChallenge(int challengeId);
  Future<Map<String, dynamic>> completeChallenge(int challengeId, {String? evidence});
  Future<List<LeaderboardUserModel>> getLeaderboard({int limit = 20});
  Future<List<AchievementModel>> getAchievements();
}

class GamificationRepository implements IGamificationRepository {
  final ApiClient apiClient;

  GamificationRepository({required this.apiClient});

  @override
  Future<List<ArenaChallengeModel>> getArenaChallenges() async {
    final response = await apiClient.get('/gamification/arena');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => ArenaChallengeModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<bool> acceptChallenge(int challengeId) async {
    final response = await apiClient.post('/gamification/arena/$challengeId/accept');
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return true;
    }
    return response.statusCode == 200;
  }

  @override
  Future<Map<String, dynamic>> completeChallenge(int challengeId, {String? evidence}) async {
    final payload = <String, dynamic>{};
    if (evidence != null && evidence.trim().isNotEmpty) {
      payload['evidence'] = evidence.trim();
    }

    final response = await apiClient.post(
      '/gamification/arena/$challengeId/complete',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'success': true};
  }

  @override
  Future<List<LeaderboardUserModel>> getLeaderboard({int limit = 20}) async {
    final response = await apiClient.get('/gamification/leaderboard', queryParameters: {'limit': limit});
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => LeaderboardUserModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    final response = await apiClient.get('/gamification/achievements');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => AchievementModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
