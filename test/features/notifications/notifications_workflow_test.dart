import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/notifications/data/models/notification_model.dart';
import 'package:probon_app/features/notifications/data/repositories/notifications_repository.dart';
import 'package:probon_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:probon_app/features/notifications/presentation/screens/notifications_screen.dart';

class MockNotificationsRepository extends Mock implements INotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepo;
  late ProviderContainer container;

  final sampleNotifications = [
    const NotificationModel(
      id: 1,
      userId: 1,
      title: 'Task Verified',
      message: 'Your evidence for Prometheus Exporter was verified (+120 XP)',
      type: 'task_verification',
      isRead: false,
      createdAt: '2026-11-02T10:00:00Z',
    ),
    const NotificationModel(
      id: 2,
      userId: 1,
      title: 'Milestone Completed',
      message: 'Alpha Architecture Release is 100% complete!',
      type: 'milestone',
      isRead: true,
      createdAt: '2026-11-02T09:00:00Z',
    ),
  ];

  setUp(() {
    mockRepo = MockNotificationsRepository();
    container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('Notifications Models & Controller Tests', () {
    test('NotificationModel parses JSON schema accurately', () {
      final notif = NotificationModel.fromJson({
        'id': 10,
        'user_id': 1,
        'title': 'New Feedback',
        'message': 'Instructor gave you 5 stars',
        'type': 'achievement',
        'is_read': 0,
        'created_at': '2026-11-02T12:00:00Z',
      });

      expect(notif.id, 10);
      expect(notif.title, 'New Feedback');
      expect(notif.isRead, false);
      expect(notif.type, 'achievement');
    });

    test('NotificationsNotifier fetches notifications and calculates unread count', () async {
      when(() => mockRepo.getNotifications(unreadOnly: any(named: 'unreadOnly'), limit: any(named: 'limit')))
          .thenAnswer((_) async => sampleNotifications);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      final state = container.read(notificationsNotifierProvider);
      expect(state.isLoading, false);
      expect(state.notifications.length, 2);
      expect(state.unreadCount, 1);
    });

    test('markAsRead updates notification state to read', () async {
      when(() => mockRepo.getNotifications(unreadOnly: any(named: 'unreadOnly'), limit: any(named: 'limit')))
          .thenAnswer((_) async => sampleNotifications);
      when(() => mockRepo.markAsRead(1)).thenAnswer((_) async => true);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      final success = await notifier.markAsRead(1);
      expect(success, true);

      final n1 = container.read(notificationsNotifierProvider).notifications.firstWhere((n) => n.id == 1);
      expect(n1.isRead, true);
      expect(container.read(notificationsNotifierProvider).unreadCount, 0);
    });

    test('markAllAsRead marks all notifications as read', () async {
      when(() => mockRepo.getNotifications(unreadOnly: any(named: 'unreadOnly'), limit: any(named: 'limit')))
          .thenAnswer((_) async => sampleNotifications);
      when(() => mockRepo.markAllAsRead()).thenAnswer((_) async => true);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      final success = await notifier.markAllAsRead();
      expect(success, true);
      expect(container.read(notificationsNotifierProvider).unreadCount, 0);
    });

    test('deleteNotification removes notification from state', () async {
      when(() => mockRepo.getNotifications(unreadOnly: any(named: 'unreadOnly'), limit: any(named: 'limit')))
          .thenAnswer((_) async => sampleNotifications);
      when(() => mockRepo.deleteNotification(2)).thenAnswer((_) async => true);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      final success = await notifier.deleteNotification(2);
      expect(success, true);
      expect(container.read(notificationsNotifierProvider).notifications.length, 1);
    });
  });

  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders NotificationsScreen with notifications and unread filter', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockRepo.getNotifications(unreadOnly: any(named: 'unreadOnly'), limit: any(named: 'limit')))
          .thenAnswer((_) async => sampleNotifications);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Task Verified'), findsOneWidget);
      expect(find.text('Milestone Completed'), findsOneWidget);
      expect(find.text('Unread (1)'), findsOneWidget);

      // Tap Unread chip
      await tester.tap(find.text('Unread (1)'));
      await tester.pumpAndSettle();

      // Only unread notification is visible
      expect(find.text('Task Verified'), findsOneWidget);
      expect(find.text('Milestone Completed'), findsNothing);
    });
  });
}
