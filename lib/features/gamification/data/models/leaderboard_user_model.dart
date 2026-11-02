class LeaderboardUserModel {
  final int id;
  final String name;
  final String username;
  final String? avatar;
  final String role;
  final int xp;
  final int points;
  final String rank;
  final int challengesCompleted;
  final int contributionCount;
  final int position;

  const LeaderboardUserModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
    this.role = 'student',
    this.xp = 0,
    this.points = 0,
    this.rank = 'Contributor Level 1',
    this.challengesCompleted = 0,
    this.contributionCount = 0,
    required this.position,
  });

  bool get isTopThree => position >= 1 && position <= 3;

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? 'Student Contributor',
      username: json['username'] as String? ?? 'contributor',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'student',
      xp: json['xp'] is int ? json['xp'] as int : (int.tryParse(json['xp']?.toString() ?? '0') ?? 0),
      points: json['points'] is int ? json['points'] as int : (int.tryParse(json['points']?.toString() ?? '0') ?? 0),
      rank: json['rank'] as String? ?? 'Contributor Level 1',
      challengesCompleted: json['challenges_completed'] is int
          ? json['challenges_completed'] as int
          : (int.tryParse(json['challenges_completed']?.toString() ?? '0') ?? 0),
      contributionCount: json['contribution_count'] is int
          ? json['contribution_count'] as int
          : (int.tryParse(json['contribution_count']?.toString() ?? '0') ?? 0),
      position: json['position'] is int
          ? json['position'] as int
          : (int.tryParse(json['position']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'role': role,
      'xp': xp,
      'points': points,
      'rank': rank,
      'challenges_completed': challengesCompleted,
      'contribution_count': contributionCount,
      'position': position,
    };
  }
}
