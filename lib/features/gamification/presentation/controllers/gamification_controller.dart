import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/arena_challenge_model.dart';
import '../../data/models/leaderboard_user_model.dart';
import '../../data/repositories/gamification_repository.dart';

final gamificationRepositoryProvider = Provider<IGamificationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return GamificationRepository(apiClient: client);
});

class GamificationState {
  final bool isLoading;
  final bool isSubmitting;
  final List<ArenaChallengeModel> challenges;
  final List<LeaderboardUserModel> leaderboard;
  final List<AchievementModel> achievements;
  final String? errorMessage;
  final int activeTab; // 0: Arena Challenges, 1: Leaderboard, 2: Badges

  const GamificationState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.challenges = const [],
    this.leaderboard = const [],
    this.achievements = const [],
    this.errorMessage,
    this.activeTab = 0,
  });

  GamificationState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<ArenaChallengeModel>? challenges,
    List<LeaderboardUserModel>? leaderboard,
    List<AchievementModel>? achievements,
    String? errorMessage,
    int? activeTab,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      challenges: challenges ?? this.challenges,
      leaderboard: leaderboard ?? this.leaderboard,
      achievements: achievements ?? this.achievements,
      errorMessage: errorMessage,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class GamificationNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    Future.microtask(() => loadAll());
    return const GamificationState(isLoading: true);
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(gamificationRepositoryProvider);
      final results = await Future.wait([
        repo.getArenaChallenges(),
        repo.getLeaderboard(),
        repo.getAchievements(),
      ]);

      state = state.copyWith(
        isLoading: false,
        challenges: results[0] as List<ArenaChallengeModel>,
        leaderboard: results[1] as List<LeaderboardUserModel>,
        achievements: results[2] as List<AchievementModel>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setActiveTab(int tabIndex) {
    state = state.copyWith(activeTab: tabIndex);
  }

  Future<bool> acceptChallenge(int challengeId) async {
    try {
      final repo = ref.read(gamificationRepositoryProvider);
      final success = await repo.acceptChallenge(challengeId);
      if (success) {
        // Optimistically update challenge state to accepted
        final updated = state.challenges.map((c) {
          if (c.id == challengeId) {
            return ArenaChallengeModel(
              id: c.id,
              title: c.title,
              description: c.description,
              xpReward: c.xpReward,
              tag: c.tag,
              difficulty: c.difficulty,
              userStatus: 'accepted',
              evidence: c.evidence,
              completedAt: c.completedAt,
            );
          }
          return c;
        }).toList();
        state = state.copyWith(challenges: updated);
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> completeChallenge(int challengeId, String evidence) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(gamificationRepositoryProvider);
      final result = await repo.completeChallenge(challengeId, evidence: evidence);
      final success = result['success'] == true;

      if (success) {
        // Optimistically update challenge state to completed
        final updated = state.challenges.map((c) {
          if (c.id == challengeId) {
            return ArenaChallengeModel(
              id: c.id,
              title: c.title,
              description: c.description,
              xpReward: c.xpReward,
              tag: c.tag,
              difficulty: c.difficulty,
              userStatus: 'completed',
              evidence: evidence,
              completedAt: DateTime.now().toIso8601String(),
            );
          }
          return c;
        }).toList();

        // Refresh user achievements & auth user XP
        final achievements = await repo.getAchievements();
        final leaderboard = await repo.getLeaderboard();

        state = state.copyWith(
          isSubmitting: false,
          challenges: updated,
          achievements: achievements,
          leaderboard: leaderboard,
        );
      } else {
        state = state.copyWith(isSubmitting: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final gamificationNotifierProvider = NotifierProvider<GamificationNotifier, GamificationState>(() {
  return GamificationNotifier();
});
