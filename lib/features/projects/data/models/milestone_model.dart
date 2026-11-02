class MilestoneModel {
  final int id;
  final int projectId;
  final String title;
  final String description;
  final String? dueDate;
  final String status;
  final int xpReward;
  final int taskCount;
  final int completedTaskCount;

  const MilestoneModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.dueDate,
    this.status = 'pending',
    this.xpReward = 100,
    this.taskCount = 0,
    this.completedTaskCount = 0,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';

  double get progressPercentage {
    if (taskCount == 0) return isCompleted ? 1.0 : 0.0;
    return (completedTaskCount / taskCount).clamp(0.0, 1.0);
  }

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] as int? ?? 0,
      projectId: json['project_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: json['due_date'] as String?,
      status: json['status'] as String? ?? 'pending',
      xpReward: json['xp_reward'] as int? ?? 100,
      taskCount: json['task_count'] as int? ?? 0,
      completedTaskCount: json['completed_task_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'status': status,
      'xp_reward': xpReward,
      'task_count': taskCount,
      'completed_task_count': completedTaskCount,
    };
  }
}
