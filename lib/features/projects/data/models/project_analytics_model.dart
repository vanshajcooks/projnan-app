class MemberAnalyticsModel {
  final int userId;
  final String name;
  final String username;
  final String? avatar;
  final String role;
  final int contributionCount;
  final int xpEarned;
  final int tasksCompleted;
  final int percentage;

  const MemberAnalyticsModel({
    required this.userId,
    required this.name,
    required this.username,
    this.avatar,
    this.role = 'member',
    this.contributionCount = 0,
    this.xpEarned = 0,
    this.tasksCompleted = 0,
    this.percentage = 0,
  });

  factory MemberAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return MemberAnalyticsModel(
      userId: json['userId'] is int ? json['userId'] as int : int.parse(json['userId'].toString()),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'member',
      contributionCount: json['contributionCount'] is int ? json['contributionCount'] as int : int.tryParse(json['contributionCount']?.toString() ?? '0') ?? 0,
      xpEarned: json['xpEarned'] is int ? json['xpEarned'] as int : int.tryParse(json['xpEarned']?.toString() ?? '0') ?? 0,
      tasksCompleted: json['tasksCompleted'] is int ? json['tasksCompleted'] as int : int.tryParse(json['tasksCompleted']?.toString() ?? '0') ?? 0,
      percentage: json['percentage'] is int ? json['percentage'] as int : int.tryParse(json['percentage']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'username': username,
      'avatar': avatar,
      'role': role,
      'contributionCount': contributionCount,
      'xpEarned': xpEarned,
      'tasksCompleted': tasksCompleted,
      'percentage': percentage,
    };
  }
}

class ActivityTypeStat {
  final int count;
  final int xp;

  const ActivityTypeStat({this.count = 0, this.xp = 0});

  factory ActivityTypeStat.fromJson(Map<String, dynamic> json) {
    return ActivityTypeStat(
      count: json['count'] is int ? json['count'] as int : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      xp: json['xp'] is int ? json['xp'] as int : int.tryParse(json['xp']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'count': count, 'xp': xp};
}

class ProjectAnalyticsModel {
  final int totalTasks;
  final int completedTasks;
  final int completionRate;
  final int totalContributions;
  final int totalXp;
  final Map<String, int> tasksByStatus;
  final Map<String, ActivityTypeStat> activityBreakdown;
  final List<MemberAnalyticsModel> memberAnalytics;

  const ProjectAnalyticsModel({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.completionRate = 0,
    this.totalContributions = 0,
    this.totalXp = 0,
    this.tasksByStatus = const {},
    this.activityBreakdown = const {},
    this.memberAnalytics = const [],
  });

  factory ProjectAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final statusMap = <String, int>{};
    if (json['tasksByStatus'] is Map) {
      (json['tasksByStatus'] as Map).forEach((k, v) {
        statusMap[k.toString()] = v is int ? v : int.tryParse(v.toString()) ?? 0;
      });
    }

    final actMap = <String, ActivityTypeStat>{};
    if (json['activityBreakdown'] is Map) {
      (json['activityBreakdown'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          actMap[k.toString()] = ActivityTypeStat.fromJson(v);
        } else if (v is Map) {
          actMap[k.toString()] = ActivityTypeStat.fromJson(Map<String, dynamic>.from(v));
        }
      });
    }

    final members = (json['memberAnalytics'] as List?)
            ?.map((m) => MemberAnalyticsModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return ProjectAnalyticsModel(
      totalTasks: json['totalTasks'] is int ? json['totalTasks'] as int : int.tryParse(json['totalTasks']?.toString() ?? '0') ?? 0,
      completedTasks: json['completedTasks'] is int ? json['completedTasks'] as int : int.tryParse(json['completedTasks']?.toString() ?? '0') ?? 0,
      completionRate: json['completionRate'] is int ? json['completionRate'] as int : int.tryParse(json['completionRate']?.toString() ?? '0') ?? 0,
      totalContributions: json['totalContributions'] is int ? json['totalContributions'] as int : int.tryParse(json['totalContributions']?.toString() ?? '0') ?? 0,
      totalXp: json['totalXp'] is int ? json['totalXp'] as int : int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
      tasksByStatus: statusMap,
      activityBreakdown: actMap,
      memberAnalytics: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completionRate': completionRate,
      'totalContributions': totalContributions,
      'totalXp': totalXp,
      'tasksByStatus': tasksByStatus,
      'activityBreakdown': activityBreakdown.map((k, v) => MapEntry(k, v.toJson())),
      'memberAnalytics': memberAnalytics.map((m) => m.toJson()).toList(),
    };
  }
}
