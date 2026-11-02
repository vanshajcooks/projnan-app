class TeamModel {
  final int id;
  final String name;
  final int? classId;
  final String? className;
  final int? leaderId;
  final String? memberRole;
  final int memberCount;
  final int projectCount;

  const TeamModel({
    required this.id,
    required this.name,
    this.classId,
    this.className,
    this.leaderId,
    this.memberRole,
    this.memberCount = 0,
    this.projectCount = 0,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      classId: json['class_id'] as int?,
      className: json['class_name'] as String?,
      leaderId: json['leader_id'] as int?,
      memberRole: json['member_role'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_id': classId,
      'class_name': className,
      'leader_id': leaderId,
      'member_role': memberRole,
      'member_count': memberCount,
      'project_count': projectCount,
    };
  }
}
