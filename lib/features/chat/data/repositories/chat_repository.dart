import '../../../../core/network/api_client.dart';
import '../models/chat_channel_model.dart';
import '../models/chat_message_model.dart';

abstract class IChatRepository {
  Future<List<ChatChannelModel>> getProjectChannels(int projectId);
  Future<List<ChatMessageModel>> getChannelMessages(int channelId, {int limit = 50});
  Future<ChatMessageModel> sendMessage(int channelId, String message);
}

class ChatRepository implements IChatRepository {
  final ApiClient apiClient;

  ChatRepository({required this.apiClient});

  @override
  Future<List<ChatChannelModel>> getProjectChannels(int projectId) async {
    final response = await apiClient.get('/chat/projects/$projectId/channels');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => ChatChannelModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<ChatMessageModel>> getChannelMessages(int channelId, {int limit = 50}) async {
    final response = await apiClient.get(
      '/chat/channels/$channelId/messages',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ChatMessageModel> sendMessage(int channelId, String message) async {
    final response = await apiClient.post(
      '/chat/channels/$channelId/messages',
      data: {'message': message.trim()},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ChatMessageModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to send message');
  }
}
