import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/message_model/message_model.dart';
import '../repo/dbrepo.dart';
part 'message_viewmodel.g.dart';

@riverpod
class MessageViewModel extends _$MessageViewModel {
  late final ChatDatabase _chatDatabase;

  @override
  Future<List<MessageModel>> build(int chatId) async {
    _chatDatabase = ref.read(chatDatabaseProvider);
    return await loadMessagesByChatId(chatId);
  }

  // Fetch messages by chat ID, with local caching
  Future<List<MessageModel>> loadMessagesByChatId(int chatId) async {
    final messages = await _chatDatabase.fetchMessagesByChatId(chatId);
    return messages;
  }

  Future<void> updateMessageStatus(String messageId, bool isSent) async {
    final currentMessages = state.value ?? [];

    // Update the message status in the state
    final updatedMessages = currentMessages
        .map((msg) => msg.id == messageId ? msg.copyWith(isSent: isSent) : msg)
        .toList();
    state = AsyncValue.data(updatedMessages);

    // Sync with the database to update the status
    await _chatDatabase.updateMessageStatus(messageId, isSent);
  }

  // Add a message and optimistically update state and cache
  Future<void> addMessage(MessageModel message, int chatId) async {
    final currentMessages = state.value ?? [];

    // Optimistic update: add the message to the state and cache
    state = AsyncValue.data([...currentMessages, message]);

    // Sync with the database
    await _chatDatabase.insertMessage(message, chatId);
  }

  // Update a message and reflect changes locally in state and cache
  Future<void> updateMessage(MessageModel message, int chatId) async {
    final currentMessages = state.value ?? [];

    // Update the message in the state and cache
    final updatedMessages = currentMessages
        .map((msg) => msg.id == message.id ? message : msg)
        .toList();
    state = AsyncValue.data(updatedMessages);

    // Sync with the database
    await _chatDatabase.updateMessage(message);
  }

  // Remove a message and update state and cache
  Future<void> removeMessage(int messageId, int chatId) async {
    final currentMessages = state.value ?? [];

    // Remove the message from the state and cache
    final updatedMessages =
        currentMessages.where((msg) => messageId != msg.id).toList();
    state = AsyncValue.data(updatedMessages);

    // Sync with the database
    await _chatDatabase.deleteMessage(messageId.toString());
  }
}
