class ChatChannelModel {
  final int id;
  final int projectId;
  final String name;
  final String type; // 'general', 'team', 'announcement'
  final String? createdAt;

  const ChatChannelModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.type = 'general',
    this.createdAt,
  });

  factory ChatChannelModel.fromJson(Map<String, dynamic> json) {
    return ChatChannelModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      projectId: json['project_id'] is int
          ? json['project_id'] as int
          : (int.tryParse(json['project_id']?.toString() ?? '0') ?? 0),
      name: json['name'] as String? ?? 'general',
      type: json['type'] as String? ?? 'general',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'type': type,
      'created_at': createdAt,
    };
  }
}
