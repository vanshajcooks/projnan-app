class ClassModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? teacherId;
  final String? teacherName;
  final String? memberRole;
  final int studentCount;
  final int teamCount;
  final int projectCount;

  const ClassModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.teacherId,
    this.teacherName,
    this.memberRole,
    this.studentCount = 0,
    this.teamCount = 0,
    this.projectCount = 0,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String?,
      teacherId: json['teacher_id'] as int?,
      teacherName: json['teacher_name'] as String?,
      memberRole: json['member_role'] as String?,
      studentCount: json['student_count'] as int? ?? 0,
      teamCount: json['team_count'] as int? ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
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
      'member_role': memberRole,
      'student_count': studentCount,
      'team_count': teamCount,
      'project_count': projectCount,
    };
  }
}
