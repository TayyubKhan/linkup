import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id, // Unique ID for the message
    required String text, // The content of the message
    required String senderId, // ID of the sender
    required String senderName, // Name of the sender
    required DateTime timestamp, // Time when the message was sent
    required bool isSender, // Whether the message is from the local user
    required bool isDocument, // Whether the message is from the local user
    required bool isSent, // Whether the message is from the local user
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
