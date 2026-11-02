class ChatMessageModel {
  final int id;
  final int channelId;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String createdAt;

  const ChatMessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      channelId: json['channel_id'] is int
          ? json['channel_id'] as int
          : (int.tryParse(json['channel_id']?.toString() ?? '0') ?? 0),
      senderId: json['sender_id'] is int
          ? json['sender_id'] as int
          : (int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0),
      senderName: json['sender_name'] as String? ?? 'Team Member',
      senderAvatar: json['sender_avatar'] as String?,
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message': message,
      'created_at': createdAt,
    };
  }
}
