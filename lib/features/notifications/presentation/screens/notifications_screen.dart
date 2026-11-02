import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_notifications.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task_verification':
        return LucideIcons.shieldCheck;
      case 'milestone':
        return LucideIcons.flag;
      case 'chat':
        return LucideIcons.messageSquare;
      case 'achievement':
        return LucideIcons.trophy;
      default:
        return LucideIcons.bell;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'task_verification':
        return AppTheme.success;
      case 'milestone':
        return const Color(0xFFFBBF24);
      case 'chat':
        return AppTheme.primaryLight;
      case 'achievement':
        return const Color(0xFFF97316);
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsNotifierProvider);
    final notifications = state.filteredNotifications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                final success = await ref
                    .read(notificationsNotifierProvider.notifier)
                    .markAllAsRead();
                if (success && context.mounted) {
                  AppToast.showSuccess(context, 'All notifications marked as read.');
                }
              },
              icon: const Icon(LucideIcons.checkCheck, size: 16),
              label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: !state.unreadOnly,
                  showCheckmark: false,
                  onSelected: (_) =>
                      ref.read(notificationsNotifierProvider.notifier).toggleUnreadFilter(false),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: !state.unreadOnly ? FontWeight.bold : FontWeight.normal,
                    color: !state.unreadOnly ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Unread (${state.unreadCount})'),
                  selected: state.unreadOnly,
                  showCheckmark: false,
                  onSelected: (_) =>
                      ref.read(notificationsNotifierProvider.notifier).toggleUnreadFilter(true),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: state.unreadOnly ? FontWeight.bold : FontWeight.normal,
                    color: state.unreadOnly ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(notificationsNotifierProvider.notifier).fetchNotifications(),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.bellOff,
                                    size: 48,
                                    color: AppTheme.textSecondary.withAlpha(100),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No notifications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Updates on your projects and tasks appear here',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            final icon = _getTypeIcon(notif.type);
                            final color = _getTypeColor(notif.type);

                            return Dismissible(
                              key: Key('notif-${notif.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(notificationsNotifierProvider.notifier)
                                    .deleteNotification(notif.id);
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                color: notif.isRead
                                    ? AppTheme.surface
                                    : AppTheme.surfaceElevated,
                                child: ListTile(
                                  onTap: () {
                                    if (!notif.isRead) {
                                      ref
                                          .read(notificationsNotifierProvider.notifier)
                                          .markAsRead(notif.id);
                                    }
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(icon, color: color, size: 20),
                                  ),
                                  title: Text(
                                    notif.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      notif.message,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                  trailing: !notif.isRead
                                      ? Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
