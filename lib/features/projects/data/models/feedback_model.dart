class FeedbackModel {
  final int id;
  final int projectId;
  final int? teamId;
  final int? userId;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final String authorRole;
  final String comment;
  final int rating; // 1-5
  final String type; // 'teacher_review', 'peer_review'
  final String createdAt;

  const FeedbackModel({
    required this.id,
    required this.projectId,
    this.teamId,
    this.userId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.authorRole = 'teacher',
    required this.comment,
    this.rating = 5,
    this.type = 'teacher_review',
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int? ?? 0,
      projectId: json['project_id'] as int? ?? 0,
      teamId: json['team_id'] as int?,
      userId: json['user_id'] as int?,
      authorId: json['author_id'] as int? ?? 0,
      authorName: json['author_name'] as String? ?? 'Reviewer',
      authorAvatar: json['author_avatar'] as String?,
      authorRole: json['author_role'] as String? ?? 'teacher',
      comment: json['comment'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      type: json['type'] as String? ?? 'teacher_review',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'team_id': teamId,
      'user_id': userId,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'author_role': authorRole,
      'comment': comment,
      'rating': rating,
      'type': type,
      'created_at': createdAt,
    };
  }
}
