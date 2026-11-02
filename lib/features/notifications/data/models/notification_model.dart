class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type; // 'task_verification', 'milestone', 'chat', 'achievement', 'system'
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'system',
    this.metadata,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? metadata,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : (int.tryParse(json['user_id']?.toString() ?? '0') ?? 0),
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
