class AchievementModel {
  final int id;
  final int? userId;
  final String title;
  final String badgeIcon;
  final String description;
  final int xpReward;
  final String? unlockedAt;

  const AchievementModel({
    required this.id,
    this.userId,
    required this.title,
    required this.badgeIcon,
    required this.description,
    this.xpReward = 50,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      title: json['title'] as String? ?? 'Achievement',
      badgeIcon: json['badge_icon'] as String? ?? '🏆',
      description: json['description'] as String? ?? '',
      xpReward: json['xp_reward'] is int
          ? json['xp_reward'] as int
          : (int.tryParse(json['xp_reward']?.toString() ?? '50') ?? 50),
      unlockedAt: json['unlocked_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'badge_icon': badgeIcon,
      'description': description,
      'xp_reward': xpReward,
      'unlocked_at': unlockedAt,
    };
  }
}
