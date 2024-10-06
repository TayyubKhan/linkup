import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'; // Importing file_picker
import 'package:linkup/features/chat/model/message_model/message_model.dart';
import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../../Components/backicon.dart';
import '../../../utils/colors.dart';
import '../viewmodel/message_viewmodel.dart';

class ChatView extends ConsumerStatefulWidget {
  final String name;
  final int chatId;
  final String deviceId; // chatId is the same as deviceId
  final Function(String, String, bool) sendMessage;
  bool isConnected;
  List<String> connectedDevices;

  ChatView({
    super.key,
    required this.chatId,
    required this.deviceId,
    required this.sendMessage,
    required this.name,
    this.isConnected = false,
    this.connectedDevices = const [],
  });

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView>
    with AutomaticKeepAliveClientMixin {
  final AutoScrollController _scrollController = AutoScrollController();
  bool isEmojiVisible = false;
  PlatformFile? _selectedFile; // Variable to store the selected file
  FilePickerResult? result;

  @override
  bool get wantKeepAlive => true; // Keep the state alive
  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the mixin works
    // Watch the ChatViewModel state
    final messageController =
        ref.watch(messageViewModelProvider(widget.chatId));
    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: false,
      backgroundColor: primaryWhite,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.name,
          style: TextStyle(color: primaryBlack, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: primaryBlack),
            onPressed: () async {
              final name = await ref.read(continueViewModelProvider.future);
              log(name.name!);
            },
          ),
        ],
        scrolledUnderElevation: 0,
      ),
      body: messageController.when(
        data: (messages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [buildMessages(messages), buildTextComposer()],
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

  Widget buildMessages(List<MessageModel> messages) {
    final width = MediaQuery.sizeOf(context).width;
    return Expanded(
      child: ListView.builder(
        reverse: true, // Ensures that the list is reversed like a chat
        itemCount: messages.length,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        itemBuilder: (context, index) {
          final message = messages[messages.length - 1 - index];
          final bool isSender = message.isSender;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              mainAxisAlignment:
                  isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: <Widget>[
                if (!isSender) ...[
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade400,
                    child: Text(
                      message.senderName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: InkWell(
                    onTap: () {
                      print(message.isSent);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      constraints: BoxConstraints(maxWidth: width * 0.7),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.grey.shade200 : primaryBlack,
                        borderRadius: isSender
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                bottomLeft: Radius.circular(12.0),
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(0.0),
                              )
                            : const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(0.0),
                                topRight: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlack,
                            offset: const Offset(0, 2),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isSender)
                            Text(
                              message.senderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 5),
                          message.isDocument
                              ? Row(
                                  children: [
                                    Icon(Icons.file_present,
                                        color: isSender
                                            ? primaryBlack
                                            : Colors.white),
                                    Flexible(
                                      child: Text(
                                        message.text.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSender
                                              ? primaryBlack
                                              : Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  message.text,
                                  style: TextStyle(
                                    color:
                                        isSender ? primaryBlack : Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('hh:mm a').format(message.timestamp),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: isSender ? primaryBlack : Colors.white,
                                ),
                              ),
                              isSender
                                  ? Icon(
                                      message.isSent
                                          ? Icons.done_all
                                          : Icons.done,
                                      color: primaryBlack,
                                      size: 12,
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();

  Widget buildTextComposer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedFile != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedFile!.name, // Show the selected file's name
                    style: TextStyle(
                      color: primaryBlack,
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red[400]),
                  onPressed: () {
                    setState(() {
                      _selectedFile = null; // Clear the selected file
                    });
                  },
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.blue),
                onPressed: () async {
                  result = await FilePicker.platform.pickFiles();
                  if (result != null && result!.files.isNotEmpty) {
                    setState(() {
                      _selectedFile =
                          result!.files.first; // Set the selected file
                    });
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: (text) {
                    _onSendMessagePressed();
                  },
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Type a message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _onSendMessagePressed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSendMessagePressed() async {
    if (_selectedFile != null) {
      // If a file is selected, send the file
      _sendFile();
      _selectedFile = null;
    } else {
      // Otherwise, send the text message
      final text = _textController.text.trim();
      if (text.isNotEmpty) {
        final name = await ref.read(continueViewModelProvider.future);
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();
        final MessageModel message = MessageModel(
          id: messageId,
          text: text,
          senderId: widget.deviceId,
          senderName: name.name!,
          timestamp: DateTime.now(),
          isSender: true,
          isDocument: false,
          isSent: false,
        );
        widget.sendMessage(_textController.text, messageId, false);

        // Save the text message in SQLite and send via Bluetooth
        ref
            .read(messageViewModelProvider(widget.chatId).notifier)
            .addMessage(message, widget.chatId);
        _textController.clear(); // Clear the text field after sending
      }
    }
  }

  Future<void> _sendFile() async {
    try {
      if (result != null && result!.files.isNotEmpty) {
        final file = result!.files.first;
        _selectedFile = file; // Store the selected file
        final fileSize = file.size; // Get the file size

        if (fileSize <= 5 * 1024 * 1024) {
          // Check if file size is less than 5 MB
          temp(file);
          // After sending the file, reset the selected file variable
        } else {
          // Handle file size error (e.g., show an error message)
          log('File size is too large');
        }
      }
    } catch (e) {
      log('Error while picking file: $e');
    }
  }

  void temp(file) async {
    final name = await ref.watch(continueViewModelProvider.future);
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final message = MessageModel(
      id: messageId,
      text: file.path!, // Display the file name as the message text
      senderId: widget.deviceId,
      senderName: name.name!,
      timestamp: DateTime.now(),
      isSender: true,
      isDocument: true, isSent: false,
    );
    widget.sendMessage(_selectedFile!.path!, messageId, true);

    // Save the file message in SQLite and send the file via Bluetooth
    ref
        .read(messageViewModelProvider(widget.chatId).notifier)
        .addMessage(message, widget.chatId);
  }
}
