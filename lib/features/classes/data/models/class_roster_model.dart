class ClassMemberModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? avatar;
  final String role;
  final int xp;
  final int points;
  final String? rank;
  final String? joinedAt;
  final String? classRole;

  const ClassMemberModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatar,
    this.role = 'student',
    this.xp = 0,
    this.points = 0,
    this.rank,
    this.joinedAt,
    this.classRole,
  });

  factory ClassMemberModel.fromJson(Map<String, dynamic> json) {
    return ClassMemberModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'student',
      xp: json['xp'] is int ? json['xp'] as int : int.tryParse(json['xp']?.toString() ?? '0') ?? 0,
      points: json['points'] is int ? json['points'] as int : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      rank: json['rank'] as String?,
      joinedAt: json['joined_at'] as String?,
      classRole: json['class_role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
      'role': role,
      'xp': xp,
      'points': points,
      'rank': rank,
      'joined_at': joinedAt,
      'class_role': classRole,
    };
  }
}

class ClassTeamSummaryModel {
  final int id;
  final String name;
  final int? leaderId;
  final String? leaderName;
  final int memberCount;
  final int projectCount;
  final String? createdAt;

  const ClassTeamSummaryModel({
    required this.id,
    required this.name,
    this.leaderId,
    this.leaderName,
    this.memberCount = 0,
    this.projectCount = 0,
    this.createdAt,
  });

  factory ClassTeamSummaryModel.fromJson(Map<String, dynamic> json) {
    return ClassTeamSummaryModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      leaderId: json['leader_id'] as int?,
      leaderName: json['leader_name'] as String?,
      memberCount: json['member_count'] is int ? json['member_count'] as int : int.tryParse(json['member_count']?.toString() ?? '0') ?? 0,
      projectCount: json['project_count'] is int ? json['project_count'] as int : int.tryParse(json['project_count']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'leader_id': leaderId,
      'leader_name': leaderName,
      'member_count': memberCount,
      'project_count': projectCount,
      'created_at': createdAt,
    };
  }
}

class ClassProjectSummaryModel {
  final int id;
  final String name;
  final String? description;
  final String? status;
  final String? teamName;

  const ClassProjectSummaryModel({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.teamName,
  });

  factory ClassProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    return ClassProjectSummaryModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      teamName: json['team_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'team_name': teamName,
    };
  }
}

class ClassRosterDetailModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? teacherId;
  final String? teacherName;
  final String? teacherEmail;
  final List<ClassMemberModel> members;
  final List<ClassTeamSummaryModel> teams;
  final List<ClassProjectSummaryModel> projects;

  const ClassRosterDetailModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.teacherId,
    this.teacherName,
    this.teacherEmail,
    this.members = const [],
    this.teams = const [],
    this.projects = const [],
  });

  factory ClassRosterDetailModel.fromJson(Map<String, dynamic> json) {
    final membersList = (json['members'] as List?)
            ?.map((m) => ClassMemberModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];
    final teamsList = (json['teams'] as List?)
            ?.map((t) => ClassTeamSummaryModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    final projectsList = (json['projects'] as List?)
            ?.map((p) => ClassProjectSummaryModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return ClassRosterDetailModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String?,
      teacherId: json['teacher_id'] as int?,
      teacherName: json['teacher_name'] as String?,
      teacherEmail: json['teacher_email'] as String?,
      members: membersList,
      teams: teamsList,
      projects: projectsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'teacher_email': teacherEmail,
      'members': members.map((m) => m.toJson()).toList(),
      'teams': teams.map((t) => t.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
    };
  }
}
