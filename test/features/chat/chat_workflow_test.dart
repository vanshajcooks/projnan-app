import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/chat/data/models/chat_channel_model.dart';
import 'package:probon_app/features/chat/data/models/chat_message_model.dart';
import 'package:probon_app/features/chat/data/repositories/chat_repository.dart';
import 'package:probon_app/features/chat/presentation/controllers/chat_controller.dart';
import 'package:probon_app/features/chat/presentation/screens/project_chat_screen.dart';

class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  late MockChatRepository mockRepo;
  late ProviderContainer container;

  const sampleChannels = [
    ChatChannelModel(id: 1, projectId: 107, name: 'general', type: 'general'),
    ChatChannelModel(id: 2, projectId: 107, name: 'announcements', type: 'announcements'),
  ];

  const sampleMessages = [
    ChatMessageModel(
      id: 1,
      channelId: 1,
      senderId: 1,
      senderName: 'Aryan Thakkar',
      message: 'Hello team, the eBPF tracer is live!',
      createdAt: '2026-11-02T10:00:00Z',
    ),
  ];

  setUp(() {
    mockRepo = MockChatRepository();
    container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('Chat Models & Notifier Tests', () {
    test('ChatChannelModel and ChatMessageModel parse correctly', () {
      final ch = ChatChannelModel.fromJson({
        'id': 10,
        'project_id': 107,
        'name': 'development',
        'type': 'team',
      });
      expect(ch.id, 10);
      expect(ch.name, 'development');

      final msg = ChatMessageModel.fromJson({
        'id': 20,
        'channel_id': 10,
        'sender_id': 2,
        'sender_name': 'Priya',
        'message': 'Working on frontend',
        'created_at': '2026-11-02T11:00:00Z',
      });
      expect(msg.id, 20);
      expect(msg.senderName, 'Priya');
      expect(msg.message, 'Working on frontend');
    });

    test('ProjectChatNotifier loads channels and messages for project', () async {
      when(() => mockRepo.getProjectChannels(107)).thenAnswer((_) async => sampleChannels);
      when(() => mockRepo.getChannelMessages(1, limit: any(named: 'limit'))).thenAnswer((_) async => sampleMessages);

      final notifier = container.read(projectChatNotifierProvider(107).notifier);
      await notifier.loadChannelsAndMessages();

      final state = container.read(projectChatNotifierProvider(107));
      expect(state.isLoading, false);
      expect(state.channels.length, 2);
      expect(state.activeChannel?.name, 'general');
      expect(state.messages.length, 1);
      expect(state.messages.first.message, 'Hello team, the eBPF tracer is live!');
    });

    test('ProjectChatNotifier sends message successfully', () async {
      when(() => mockRepo.getProjectChannels(107)).thenAnswer((_) async => sampleChannels);
      when(() => mockRepo.getChannelMessages(1, limit: any(named: 'limit'))).thenAnswer((_) async => sampleMessages);

      const newMsg = ChatMessageModel(
        id: 2,
        channelId: 1,
        senderId: 1,
        senderName: 'Aryan Thakkar',
        message: 'Great work!',
        createdAt: '2026-11-02T10:05:00Z',
      );
      when(() => mockRepo.sendMessage(1, 'Great work!')).thenAnswer((_) async => newMsg);

      final notifier = container.read(projectChatNotifierProvider(107).notifier);
      await notifier.loadChannelsAndMessages();

      final success = await notifier.sendMessage('Great work!');
      expect(success, true);

      final state = container.read(projectChatNotifierProvider(107));
      expect(state.messages.length, 2);
      expect(state.messages.last.message, 'Great work!');
    });
  });

  group('ProjectChatScreen Widget Tests', () {
    testWidgets('renders ProjectChatScreen with channels and allows sending message', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockRepo.getProjectChannels(107)).thenAnswer((_) async => sampleChannels);
      when(() => mockRepo.getChannelMessages(1, limit: any(named: 'limit'))).thenAnswer((_) async => sampleMessages);

      const sentMsg = ChatMessageModel(
        id: 2,
        channelId: 1,
        senderId: 1,
        senderName: 'Me',
        message: 'Excited for alpha release!',
        createdAt: '2026-11-02T10:10:00Z',
      );
      when(() => mockRepo.sendMessage(1, 'Excited for alpha release!')).thenAnswer((_) async => sentMsg);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ProjectChatScreen(projectId: 107, projectName: 'Cloud Monitor Platform'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Channel chips and message content
      expect(find.text('# general'), findsWidgets);
      expect(find.text('# announcements'), findsOneWidget);
      expect(find.text('Hello team, the eBPF tracer is live!'), findsOneWidget);

      // Enter message
      final input = find.byType(TextField);
      await tester.enterText(input, 'Excited for alpha release!');
      await tester.pumpAndSettle();

      // Tap Send
      await tester.tap(find.byIcon(LucideIcons.send));
      await tester.pumpAndSettle();

      verify(() => mockRepo.sendMessage(1, 'Excited for alpha release!')).called(1);
      expect(find.text('Excited for alpha release!'), findsOneWidget);
    });
  });
}
