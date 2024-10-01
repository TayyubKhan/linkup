import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repo/dbrepo.dart';
part 'message_viewmodel.g.dart';
@riverpod
class MessageViewModel extends _$MessageViewModel {
  late final ChatDatabase _chatDatabase;
  Map<int, List<Message>> _cachedMessagesByChatId = {};

  @override
  Future<List<Message>> build(int chatId) async {
    _chatDatabase = ref.read(chatDatabaseProvider);
    return await loadMessagesByChatId(chatId);
  }

  // Fetch messages by chat ID, with local caching
  Future<List<Message>> loadMessagesByChatId(int chatId) async {
    if (_cachedMessagesByChatId.containsKey(chatId)) {
      return _cachedMessagesByChatId[chatId]!;
    }

    final messages = await _chatDatabase.fetchMessagesByChatId(chatId);
    _cachedMessagesByChatId[chatId] = messages; // Cache result
    return messages;
  }

  // Add a message and optimistically update state and cache
  Future<void> addMessage(Message message, int chatId) async {
    final currentMessages = state.value ?? [];

    // Optimistic update: add the message to the state and cache
    state = AsyncValue.data([...currentMessages, message]);
    _cachedMessagesByChatId[chatId] = [...currentMessages, message];

    // Sync with the database
    await _chatDatabase.insertMessage(message, chatId);
  }

  // Update a message and reflect changes locally in state and cache
  Future<void> updateMessage(Message message, int chatId) async {
    final currentMessages = state.value ?? [];

    // Update the message in the state and cache
    final updatedMessages = currentMessages.map((msg) => msg.id == message.id ? message : msg).toList();
    state = AsyncValue.data(updatedMessages);
    _cachedMessagesByChatId[chatId] = updatedMessages;

    // Sync with the database
    await _chatDatabase.updateMessage(message);
  }

  // Remove a message and update state and cache
  Future<void> removeMessage(int messageId, int chatId) async {
    final currentMessages = state.value ?? [];

    // Remove the message from the state and cache
    final updatedMessages = currentMessages.where((msg) => msg.id != messageId).toList();
    state = AsyncValue.data(updatedMessages);
    _cachedMessagesByChatId[chatId] = updatedMessages;

    // Sync with the database
    await _chatDatabase.deleteMessage(messageId);
  }
}
