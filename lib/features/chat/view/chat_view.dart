import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

import 'package:linkup/Components/backicon.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: 'user1'); // Your user ID
  bool isEmojiVisible = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = _generateMessages(); // Example messages
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (v, b) {
        setState(() {
          isEmojiVisible = false;
        });
      },
      child: Scaffold(
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
        body: Stack(
          children: [
            Opacity(
              opacity: 0.1,
              child: Image(
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                  image: const AssetImage('assets/back.jpg')),
            ),
            Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: const DefaultChatTheme(
                backgroundColor: Colors.transparent,
                inputBackgroundColor: Color(0xff1a1a1a),
                inputTextColor: Color(0xffF7F7F7),
                primaryColor: Color(0xff1a1a1a),
              ),
              customBottomWidget: _buildInputArea(),
            ),
            isEmojiVisible ? _buildEmojiPicker() : Container(),
          ],
        ),
      ),
    );
  }

  List<types.Message> _generateMessages() {
    return List.generate(10, (index) {
      return types.TextMessage(
        author: _user,
        id: Random().nextInt(100).toString(),
        text: 'Message $index',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: Random().nextInt(100).toString(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });
  }

  Widget _buildInputArea() {
    return Container(
      color: const Color(0xffF7F7F7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            icon:
                const Icon(Icons.emoji_emotions_outlined, color: Color(0xff1a1a1a)),
            onPressed: () {
              setState(() {
                isEmojiVisible = !isEmojiVisible;
              });
            },
          ),
          // File Picker button
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xff1a1a1a)),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                final pickedFile = result.files.first;
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Color(0xffF7F7F7)),
              decoration: const InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onTap: () {
                setState(() {
                  isEmojiVisible = false;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xff1a1a1a)),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _handleSendPressed(types.PartialText(text: _controller.text));
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _controller.text += emoji.emoji;
      },
      config: const Config(
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 32,
          verticalSpacing: 0,
          horizontalSpacing: 0,
        ),
        categoryViewConfig: CategoryViewConfig(
          indicatorColor: Colors.blue,
          iconColor: Colors.grey,
          iconColorSelected: Colors.blue,
        ),
        skinToneConfig: SkinToneConfig(),
        bottomActionBarConfig: BottomActionBarConfig(),
        height: 256,
        swapCategoryAndBottomBar: false,
        checkPlatformCompatibility: true,
      ),
    );
  }
}
