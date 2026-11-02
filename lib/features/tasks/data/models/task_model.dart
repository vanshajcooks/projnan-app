class TaskModel {
  final int id;
  final int projectId;
  final String? projectName;
  final int? milestoneId;
  final String? milestoneTitle;
  final String title;
  final String? description;
  final int? assignedToId;
  final String? assignedToName;
  final String? assignedToAvatar;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String? deadline;
  final String taskType; // 'daily', 'weekly', 'monthly'
  final String status; // 'Planned', 'In Progress', 'Verification Pending', 'Completed'
  final int xpValue;
  final String? verificationStatus;

  const TaskModel({
    required this.id,
    required this.projectId,
    this.projectName,
    this.milestoneId,
    this.milestoneTitle,
    required this.title,
    this.description,
    this.assignedToId,
    this.assignedToName,
    this.assignedToAvatar,
    this.priority = 'medium',
    this.deadline,
    this.taskType = 'weekly',
    this.status = 'Planned',
    this.xpValue = 50,
    this.verificationStatus,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'in progress';
  bool get isPendingVerification => status.toLowerCase() == 'verification pending';

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      projectId: json['project_id'] is int
          ? json['project_id'] as int
          : (int.tryParse(json['project_id']?.toString() ?? '0') ?? 0),
      projectName: json['project_name'] as String?,
      milestoneId: json['milestone_id'] != null ? int.tryParse(json['milestone_id'].toString()) : null,
      milestoneTitle: json['milestone_title'] as String?,
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String?,
      assignedToId: json['assigned_to_id'] != null ? int.tryParse(json['assigned_to_id'].toString()) : null,
      assignedToName: json['assigned_to_name'] as String?,
      assignedToAvatar: json['assigned_to_avatar'] as String?,
      priority: (json['priority'] as String?)?.toLowerCase() ?? 'medium',
      deadline: json['deadline'] as String?,
      taskType: (json['task_type'] as String?)?.toLowerCase() ?? 'weekly',
      status: json['status'] as String? ?? 'Planned',
      xpValue: json['xp_value'] is int
          ? json['xp_value'] as int
          : (int.tryParse(json['xp_value']?.toString() ?? '50') ?? 50),
      verificationStatus: json['verification_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'project_name': projectName,
      'milestone_id': milestoneId,
      'milestone_title': milestoneTitle,
      'title': title,
      'description': description,
      'assigned_to_id': assignedToId,
      'assigned_to_name': assignedToName,
      'assigned_to_avatar': assignedToAvatar,
      'priority': priority,
      'deadline': deadline,
      'task_type': taskType,
      'status': status,
      'xp_value': xpValue,
      'verification_status': verificationStatus,
    };
  }

  TaskModel copyWith({
    int? id,
    int? projectId,
    String? projectName,
    int? milestoneId,
    String? milestoneTitle,
    String? title,
    String? description,
    int? assignedToId,
    String? assignedToName,
    String? assignedToAvatar,
    String? priority,
    String? deadline,
    String? taskType,
    String? status,
    int? xpValue,
    String? verificationStatus,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      milestoneId: milestoneId ?? this.milestoneId,
      milestoneTitle: milestoneTitle ?? this.milestoneTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedToAvatar: assignedToAvatar ?? this.assignedToAvatar,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      xpValue: xpValue ?? this.xpValue,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
