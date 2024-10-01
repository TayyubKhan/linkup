import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChatModelScreen extends StatefulWidget {
  final BluetoothDevice device;
  ChatModelScreen({required this.device});

  @override
  _ChatModelScreenState createState() => _ChatModelScreenState();
}

class _ChatModelScreenState extends State<ChatModelScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    receivemessage(widget.device);
  }

  void sendmessage(String text) {
    sendmessage(text);
    setState(() {
      messages.add('Me: $text');
    });
    _controller.clear();
  }

  void receivemessage(BluetoothDevice device) {
    // Listen for incoming messages here
    // Add to messages list and update UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChatModel with ${widget.device.name}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Enter message'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  sendmessage(_controller.text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
