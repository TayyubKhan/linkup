import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../../Components/backicon.dart';
import '../viewmodel/message_viewmodel.dart';

class ChatView extends ConsumerStatefulWidget {
  final int chatId;

  const ChatView({super.key, required this.chatId});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();
  final _user = const types.User(id: 'user1');
  bool isEmojiVisible = false;

  @override
  bool get wantKeepAlive => true; // Keep the state alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super to ensure the mixin works
    final messageController =
        ref.watch(messageViewModelProvider(widget.chatId));
    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: false,
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Atif',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xff1a1a1a)),
            onPressed: () {},
          ),
        ],
        scrolledUnderElevation: 0,
      ),
      body: messageController.when(
        data: (messages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Scroll to the bottom when new messages are added
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
          return chat.Chat(
            messages: messages.reversed.toList(),
            onSendPressed: _onSendPressed,
            user: _user,
            theme: const chat.DefaultChatTheme(
              inputBackgroundColor: Color(0xff1a1a1a),
              inputTextColor: Color(0xffF7F7F7),
            ),
            customBottomWidget: _buildInputArea(),
            scrollController: _scrollController, // Assign the ScrollController
            scrollPhysics:
                const BouncingScrollPhysics(), // Adjust scroll physics
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          log('Error: $error');
          log('StackTrace: $stackTrace');
          return Center(child: Text('Error occurred: $error'));
        },
      ),
    );
  }

  void _onSendPressed(types.PartialText partialText) {
    final text = partialText.text;
    if (text.isNotEmpty) {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final message = types.TextMessage(
        author: _user,
        id: messageId,
        text: text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      ref
          .read(messageViewModelProvider(widget.chatId).notifier)
          .addMessage(message, widget.chatId);
      _controller.clear(); // Clear the input
    }
  }

  Widget _buildInputArea() {
    return Container(
      color: const Color(0xff1a1a1a),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isEmojiVisible ? Icons.keyboard : Icons.emoji_emotions),
            onPressed: _toggleEmojiVisibility,
            color: Colors.white,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () =>
                _onSendPressed(types.PartialText(text: _controller.text)),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  void _toggleEmojiVisibility() {
    setState(() {
      isEmojiVisible = !isEmojiVisible;
    });
  }
}
