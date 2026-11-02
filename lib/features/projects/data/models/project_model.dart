class ProjectModel {
  final int id;
  final String name;
  final String? description;
  final int? teamId;
  final String? teamName;
  final int? classId;
  final String? className;
  final String status; // 'Active', 'Completed', 'Archived'
  final int progress; // 0..100
  final List<String> goals;
  final List<String> tags;
  final int taskCount;
  final int completedTaskCount;
  final String? createdAt;

  const ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.teamId,
    this.teamName,
    this.classId,
    this.className,
    this.status = 'Active',
    this.progress = 0,
    this.goals = const [],
    this.tags = const [],
    this.taskCount = 0,
    this.completedTaskCount = 0,
    this.createdAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed' || progress == 100;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic field) {
      if (field == null) return [];
      if (field is List) return field.map((e) => e.toString()).toList();
      return [];
    }

    return ProjectModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? 'Untitled Project',
      description: json['description'] as String?,
      teamId: json['team_id'] != null ? int.tryParse(json['team_id'].toString()) : null,
      teamName: json['team_name'] as String? ?? json['teamName'] as String?,
      classId: json['class_id'] != null ? int.tryParse(json['class_id'].toString()) : null,
      className: json['class_name'] as String? ?? json['className'] as String?,
      status: json['status'] as String? ?? 'Active',
      progress: json['progress'] is int
          ? json['progress'] as int
          : (int.tryParse(json['progress']?.toString() ?? '0') ?? 0),
      goals: parseList(json['goals']),
      tags: parseList(json['tags']),
      taskCount: json['task_count'] is int
          ? json['task_count'] as int
          : (int.tryParse(json['task_count']?.toString() ?? '0') ?? 0),
      completedTaskCount: json['completed_task_count'] is int
          ? json['completed_task_count'] as int
          : (int.tryParse(json['completed_task_count']?.toString() ?? '0') ?? 0),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'team_id': teamId,
      'team_name': teamName,
      'class_id': classId,
      'class_name': className,
      'status': status,
      'progress': progress,
      'goals': goals,
      'tags': tags,
      'task_count': taskCount,
      'completed_task_count': completedTaskCount,
      'created_at': createdAt,
    };
  }
}
