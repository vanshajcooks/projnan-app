import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/gamification_controller.dart';
import '../widgets/achievement_badge_card.dart';
import '../widgets/arena_challenge_card.dart';
import '../widgets/leaderboard_tile.dart';

class WeeklyArenaScreen extends ConsumerStatefulWidget {
  const WeeklyArenaScreen({super.key});

  @override
  ConsumerState<WeeklyArenaScreen> createState() => _WeeklyArenaScreenState();
}

class _WeeklyArenaScreenState extends ConsumerState<WeeklyArenaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gamificationNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Weekly Arena'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFBBF24),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFBBF24),
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Arena Challenges'),
            Tab(text: 'Leaderboard'),
            Tab(text: 'Badges'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildArenaChallengesTab(state),
                _buildLeaderboardTab(state),
                _buildBadgesTab(state),
              ],
            ),
    );
  }

  // TAB 1: Challenges
  Widget _buildArenaChallengesTab(GamificationState state) {
    final challenges = state.challenges;

    return RefreshIndicator(
      onRefresh: () => ref.read(gamificationNotifierProvider.notifier).loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFBBF24).withAlpha(45),
                  AppTheme.primary.withAlpha(40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFBBF24).withAlpha(90)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.swords, size: 26, color: Color(0xFFFBBF24)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Arena Active',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Solve coding challenges, review peers, and earn bonus community XP every week.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Open Challenges',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${challenges.where((c) => c.isCompleted).length}/${challenges.length} Done',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (challenges.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No active arena challenges currently.'),
              ),
            )
          else
            ...challenges.map((c) => ArenaChallengeCard(challenge: c)),
        ],
      ),
    );
  }

  // TAB 2: Leaderboard
  Widget _buildLeaderboardTab(GamificationState state) {
    final leaderboard = state.leaderboard;

    return RefreshIndicator(
      onRefresh: () => ref.read(gamificationNotifierProvider.notifier).loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          const Row(
            children: [
              Icon(LucideIcons.trophy, size: 18, color: Color(0xFFFBBF24)),
              SizedBox(width: 8),
              Text(
                'Top Contributors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (leaderboard.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No leaderboard rankings recorded yet.'),
              ),
            )
          else
            ...leaderboard.map((u) => LeaderboardTile(user: u)),
        ],
      ),
    );
  }

  // TAB 3: Badges
  Widget _buildBadgesTab(GamificationState state) {
    final achievements = state.achievements;

    return RefreshIndicator(
      onRefresh: () => ref.read(gamificationNotifierProvider.notifier).loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          const Row(
            children: [
              Icon(LucideIcons.medal, size: 18, color: Color(0xFFFBBF24)),
              SizedBox(width: 8),
              Text(
                'My Badges & Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (achievements.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('Complete challenges and tasks to unlock badges!'),
              ),
            )
          else
            ...achievements.map((a) => AchievementBadgeCard(achievement: a)),
        ],
      ),
    );
  }
}
