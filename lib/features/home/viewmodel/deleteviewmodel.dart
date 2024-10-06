import 'package:linkup/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:linkup/features/home/viewmodel/home_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'delete_state.dart';
part 'deleteviewmodel.g.dart';

@riverpod
class DeleteViewModel extends _$DeleteViewModel {
  @override
  DeleteState build() {
    return const DeleteState(); // Initialize with an empty state
  }

  // Toggle chat selection
  void toggleChatSelection(int chatId) {
    // Create a new list from the current selectedChatIds
    final updatedSelectedChatIds = List<int>.from(state.selectedChatIds);

    if (updatedSelectedChatIds.contains(chatId)) {
      updatedSelectedChatIds
          .remove(chatId); // Remove chatId if already selected
    } else {
      updatedSelectedChatIds.add(chatId); // Add chatId if not selected
    }

    // Update the state with the new selectedChatIds
    state = state.copyWith(selectedChatIds: updatedSelectedChatIds);
  }

  void deleteSelectedChats() {
    // Loop through selected chat IDs and call deleteChatById for each
    for (final chatId in state.selectedChatIds) {
      ref.read(homeViewModelProvider.notifier).deleteChat(chatId);
    }

    // Remove the deleted chats from the local state
    final remainingChats = state.chats
        .where((chat) => !state.selectedChatIds.contains(chat.id))
        .toList();

    // Update the state with the new list of chats and clear selectedChatIds
    state = state.copyWith(
      chats: remainingChats,
      selectedChatIds: [], // Clear selected IDs after deletion
    );
  }

  // Check if any chat is selected
  bool isAnyChatSelected() {
    return state.selectedChatIds.isNotEmpty;
  }
}
