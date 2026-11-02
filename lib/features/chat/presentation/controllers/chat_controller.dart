import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../data/models/chat_channel_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ChatRepository(apiClient: client);
});

class ChatState {
  final bool isLoading;
  final bool isSending;
  final List<ChatChannelModel> channels;
  final ChatChannelModel? activeChannel;
  final List<ChatMessageModel> messages;
  final String? errorMessage;

  const ChatState({
    this.isLoading = true,
    this.isSending = false,
    this.channels = const [],
    this.activeChannel,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    List<ChatChannelModel>? channels,
    ChatChannelModel? activeChannel,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      channels: channels ?? this.channels,
      activeChannel: activeChannel ?? this.activeChannel,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}

class ProjectChatNotifier extends Notifier<ChatState> {
  final int projectId;

  ProjectChatNotifier(this.projectId);

  @override
  ChatState build() {
    Future.microtask(() => loadChannelsAndMessages());
    return const ChatState(isLoading: true);
  }

  Future<void> loadChannelsAndMessages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final channels = await repo.getProjectChannels(projectId);

      ChatChannelModel? targetChannel = state.activeChannel;
      if (targetChannel == null && channels.isNotEmpty) {
        targetChannel = channels.first;
      }

      List<ChatMessageModel> messages = [];
      if (targetChannel != null) {
        messages = await repo.getChannelMessages(targetChannel.id);
      }

      state = state.copyWith(
        isLoading: false,
        channels: channels,
        activeChannel: targetChannel,
        messages: messages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectChannel(ChatChannelModel channel) async {
    if (state.activeChannel?.id == channel.id) return;
    state = state.copyWith(activeChannel: channel, isLoading: true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final messages = await repo.getChannelMessages(channel.id);
      state = state.copyWith(isLoading: false, messages: messages);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> sendMessage(String text) async {
    final active = state.activeChannel;
    if (active == null || text.trim().isEmpty) return false;

    state = state.copyWith(isSending: true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final sent = await repo.sendMessage(active.id, text.trim());
      state = state.copyWith(
        isSending: false,
        messages: [...state.messages, sent],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: e.toString());
      return false;
    }
  }
}

final projectChatNotifierProvider =
    NotifierProvider.autoDispose.family<ProjectChatNotifier, ChatState, int>(
  (arg) => ProjectChatNotifier(arg),
);
