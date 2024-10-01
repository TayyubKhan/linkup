import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../chat/model/chat_model.dart';
import '../../chat/repo/dbrepo.dart';

part 'home_viewmodel.g.dart'; // Code generation part

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final ChatDatabase _chatDatabase;

  // Initialize the notifier with ChatDatabase
  @override
  Future<List<Chat>> build() async {
    _chatDatabase = ref.read(chatDatabaseProvider);
    // Fetch the chats from the database
    return await loadChats();
  }

  // Fetch chats from the database
  Future<List<Chat>> loadChats() async {
    return await _chatDatabase.fetchChats();
  }

  // Add a new chat and reload chats
  Future<void> addChat(Chat chat) async {
    // Use AsyncValue.guard to reload chats after adding
    state = await AsyncValue.guard(() async {
      await _chatDatabase.insertChat(chat);
      return loadChats(); // return the updated list of chats
    });
  }

  // Delete a chat and reload chats
  Future<void> deleteChat(int chatId) async {
    // Use AsyncValue.guard to reload chats after deletion
    state = await AsyncValue.guard(() async {
      await _chatDatabase.deleteChat(chatId);
      return loadChats(); // return the updated list of chats
    });
  }
}
