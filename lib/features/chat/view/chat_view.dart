import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool isEmojiVisible = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Contact Name', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 20, // Example message count
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Align(
                    alignment: index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Text(
                        'Message $index',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildChatInputField(),
          isEmojiVisible ? _buildEmojiPicker() : Container(),
        ],
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions, color: Colors.white),
            onPressed: () {
              setState(() {
                isEmojiVisible = !isEmojiVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.white),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                print('File selected: ${result.files.single.name}');
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
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
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              // Implement send message logic here
              print('Message: ${_controller.text}');
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category,emoji) {
        setState(() {
          _controller.text += emoji.emoji;
        });
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
        skinToneConfig: SkinToneConfig(
          enabled: true,
          indicatorColor: Colors.white,
        ),

        height: 256,
        swapCategoryAndBottomBar: false,
        checkPlatformCompatibility: true,
      ),
    );
  }
}