import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<INotificationsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationsRepository(apiClient: client);
});

class NotificationsState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final bool unreadOnly;
  final String? errorMessage;

  const NotificationsState({
    this.isLoading = true,
    this.notifications = const [],
    this.unreadOnly = false,
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredNotifications {
    if (unreadOnly) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    bool? unreadOnly,
    String? errorMessage,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    Future.microtask(() => fetchNotifications());
    return const NotificationsState(isLoading: true);
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final list = await repo.getNotifications(unreadOnly: false);
      state = state.copyWith(isLoading: false, notifications: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleUnreadFilter(bool unreadOnly) {
    state = state.copyWith(unreadOnly: unreadOnly);
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.markAsRead(notificationId);
      final updated = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final success = await repo.markAllAsRead();
      if (success) {
        final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
        state = state.copyWith(notifications: updated);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final success = await repo.deleteNotification(notificationId);
      if (success) {
        final updated = state.notifications.where((n) => n.id != notificationId).toList();
        state = state.copyWith(notifications: updated);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(() {
  return NotificationsNotifier();
});
