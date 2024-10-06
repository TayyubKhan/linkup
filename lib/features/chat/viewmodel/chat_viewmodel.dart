import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/chat_model.dart';
import '../repo/dbrepo.dart';
import '../model/message_model/message_model.dart';

part 'chat_viewmodel.g.dart'; // Code generation part

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late final ChatDatabase _chatDatabase;

  @override
  Future<List<Chat>> build() async {
    _chatDatabase = ref.read(chatDatabaseProvider);
    return await loadChats();
  }

  Future<int?> getChatId(String name) async {
    final chat = await _chatDatabase.getChatIdByName(name);
    return chat;
  }

  // Fetch chats from the database, using cache if available
  Future<List<Chat>> loadChats() async {
    final chats = await _chatDatabase.fetchChats();
    return chats;
  }

  // Add a new chat and optimistically update state and cache
  Future<void> addChat(Chat chat) async {
    final currentChats = state.value ?? [];
    state = AsyncValue.data([...currentChats, chat]);
    await _chatDatabase.insertChat(chat);
  }

  // Update a chat and reflect changes locally in state and cache
  Future<void> updateChat(Chat chat) async {
    final currentChats = state.value ?? [];
    final updatedChats =
    currentChats.map((c) => c.id == chat.id ? chat : c).toList();
    state = AsyncValue.data(updatedChats);
    await _chatDatabase.updateChat(chat);
  }

  // Remove a chat and update state and cache
  Future<void> removeChat(int chatId) async {
    final currentChats = state.value ?? [];
    final updatedChats = currentChats.where((c) => c.id != chatId).toList();
    state = AsyncValue.data(updatedChats);
    await _chatDatabase.deleteChat(chatId);
  }

  // Fetch unsent messages by chat name
  Future<List<Map<String, dynamic>>> fetchUnsentMessages(String chatName) async {
    final unsentMessages = await _chatDatabase.fetchUnsentMessages(chatName);
    return unsentMessages;
  }
  Future<void> updateMessageStatus(String messageId, bool isSent) async {
    // Update the message status in the database
    await _chatDatabase.updateMessageStatus(messageId, isSent);

    // Optionally refresh the local state or specific messages
    final currentChats = state.value ?? [];

    // Assuming you want to fetch the updated messages for a specific chat
    for (var chat in currentChats) {
      await fetchUnsentMessages(chat.chatName);
    }
    state = AsyncValue.data(currentChats);
  }

}
