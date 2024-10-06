import 'package:freezed_annotation/freezed_annotation.dart';

import '../../chat/model/chat_model.dart';

part 'delete_state.freezed.dart';

@freezed
class DeleteState with _$DeleteState {
  const factory DeleteState({
    @Default([]) List<Chat> chats,  // List of all chats
    @Default([]) List<int> selectedChatIds,  // Selected chat IDs
  }) = _DeleteState;
}
