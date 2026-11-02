import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class INotificationsRepository {
  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false, int limit = 50});
  Future<bool> markAsRead(int notificationId);
  Future<bool> markAllAsRead();
  Future<bool> deleteNotification(int notificationId);
}

class NotificationsRepository implements INotificationsRepository {
  final ApiClient apiClient;

  NotificationsRepository({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false, int limit = 50}) async {
    final response = await apiClient.get(
      '/notifications',
      queryParameters: {
        'unreadOnly': unreadOnly,
        'limit': limit,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List;
      return list.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    final response = await apiClient.put('/notifications/$notificationId/read');
    return response.statusCode == 200;
  }

  @override
  Future<bool> markAllAsRead() async {
    final response = await apiClient.put('/notifications/read-all');
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    final response = await apiClient.delete('/notifications/$notificationId');
    return response.statusCode == 200;
  }
}
