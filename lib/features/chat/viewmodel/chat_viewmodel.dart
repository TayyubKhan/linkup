import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/chat_model.dart';
import '../repo/dbrepo.dart';

part 'chat_viewmodel.g.dart'; // Code generation part

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late final ChatDatabase _chatDatabase;
  List<Chat>? _cachedChats;

  @override
  Future<List<Chat>> build() async {
    _chatDatabase = ref.read(chatDatabaseProvider);
    return await loadChats();
  }

  // Fetch chats from the database, using cache if available
  Future<List<Chat>> loadChats() async {
    if (_cachedChats != null) {
      return _cachedChats!;
    }

    final chats = await _chatDatabase.fetchChats();
    _cachedChats = chats; // Cache the result
    return chats;
  }

  // Add a new chat and optimistically update state and cache
  Future<void> addChat(Chat chat) async {
    final currentChats = state.value ?? [];

    // Optimistic update: immediately add the chat to the state and cache
    state = AsyncValue.data([...currentChats, chat]);
    _cachedChats = [...currentChats, chat];

    // Sync with the database
    await _chatDatabase.insertChat(chat);
  }

  // Update a chat and reflect changes locally in state and cache
  Future<void> updateChat(Chat chat) async {
    final currentChats = state.value ?? [];

    // Update the chat in the state and cache
    final updatedChats = currentChats.map((c) => c.id == chat.id ? chat : c).toList();
    state = AsyncValue.data(updatedChats);
    _cachedChats = updatedChats;

    // Sync with the database
    await _chatDatabase.updateChat(chat);
  }

  // Remove a chat and update state and cache
  Future<void> removeChat(int chatId) async {
    final currentChats = state.value ?? [];

    // Remove the chat from the state and cache
    final updatedChats = currentChats.where((c) => c.id != chatId).toList();
    state = AsyncValue.data(updatedChats);
    _cachedChats = updatedChats;

    // Sync with the database
    await _chatDatabase.deleteChat(chatId);
  }
}
