class ArenaChallengeModel {
  final int id;
  final String title;
  final String description;
  final int xpReward;
  final String tag;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final String userStatus; // 'available', 'accepted', 'completed'
  final String? evidence;
  final String? completedAt;

  const ArenaChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.xpReward = 150,
    this.tag = 'Challenge',
    this.difficulty = 'Medium',
    this.userStatus = 'available',
    this.evidence,
    this.completedAt,
  });

  bool get isAvailable => userStatus.toLowerCase() == 'available';
  bool get isAccepted => userStatus.toLowerCase() == 'accepted';
  bool get isCompleted => userStatus.toLowerCase() == 'completed';

  factory ArenaChallengeModel.fromJson(Map<String, dynamic> json) {
    return ArenaChallengeModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      title: json['title'] as String? ?? 'Arena Challenge',
      description: json['description'] as String? ?? '',
      xpReward: json['xp_reward'] is int
          ? json['xp_reward'] as int
          : (int.tryParse(json['xp_reward']?.toString() ?? '150') ?? 150),
      tag: json['tag'] as String? ?? 'Challenge',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      userStatus: json['user_status'] as String? ?? 'available',
      evidence: json['evidence'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xp_reward': xpReward,
      'tag': tag,
      'difficulty': difficulty,
      'user_status': userStatus,
      'evidence': evidence,
      'completed_at': completedAt,
    };
  }
}
