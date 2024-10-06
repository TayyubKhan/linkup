import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:linkup/features/chat/view/chat_view.dart';
import 'package:linkup/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:linkup/features/chat/viewmodel/message_viewmodel.dart';
import 'package:linkup/features/home/viewmodel/deleteviewmodel.dart';
import 'package:linkup/features/home/viewmodel/home_viewmodel.dart';
import 'package:linkup/main.dart';
import 'package:location/location.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common_viewmodel/nearby_communation_service/nearby_communication_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/routes/routesName.dart';
import '../../chat/model/chat_model.dart';
import '../../chat/model/message_model/message_model.dart';
import '../../continue/viewModel/ContinueViewModel.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    permission();
    Future.microtask(
        () => ref.read(homeViewModelProvider.notifier).loadChats());
    startAdvertising();
  }

  Future<void> permission() async {
    // Request location permission
    await Permission.location.request();
    await Location.instance.requestService();

    // Request external storage permission
    await Permission.storage.request();

    // Request Bluetooth permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    // Android 12+
    await Permission.nearbyWifiDevices.request();
  }

  Map<int, String> map = {};
  bool isSelecting = false;
  String? tempFileUri; //reference to the file currently being transferred

  @override
  Widget build(BuildContext context) {
    final deleteViewModel = ref.watch(deleteViewModelProvider);
    final deleteViewModelNotifier = ref.read(deleteViewModelProvider.notifier);
    final selectedChats = deleteViewModel.selectedChatIds;
    final chatList = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("LinkUp", style: Theme.of(context).textTheme.titleLarge),
        automaticallyImplyLeading: false,
        actions: [
          if (isSelecting) // Show delete button when chats are selected
            IconButton(
              icon: Icon(
                Icons.delete,
                color: primaryBlack,
              ),
              onPressed: () {
                deleteViewModelNotifier
                    .deleteSelectedChats(); // Delete selected chats
                setState(() {
                  isSelecting = false; // Exit selection mode
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.settingView);
              },
              child: Icon(
                Icons.settings,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          )
        ],
      ),
      body: chatList.when(
        data: (chats) => chats.isEmpty
            ? const Center(child: Text('No Chats Available'))
            : ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, i) {
                  final chat = chats[i];
                  final isSelected = selectedChats.contains(chat.id);
                  ref.watch(messageViewModelProvider(chat.id)).maybeWhen(
                        data: (messages) => messages.isNotEmpty
                            ? messages.last // Fetch the last message
                            : null,
                        orElse: () => null,
                      );
                  return Dismissible(
                    key: Key(chat.id.toString()),
                    onDismissed: (_) {
                      ref
                          .read(homeViewModelProvider.notifier)
                          .deleteChat(chat.id);
                    },
                    background: Container(color: Colors.red),
                    child: ListTile(
                      leading: isSelecting
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                deleteViewModelNotifier
                                    .toggleChatSelection(chat.id);
                                if (selectedChats.isEmpty) {
                                  setState(() {
                                    isSelecting = false;
                                  });
                                }
                              },
                            )
                          : const Icon(Icons.chat),
                      title: Text(chat.chatName),
                      subtitle: Text('Created at: ${chat.createdAt}'),
                      onTap: () async {
                        if (isSelecting) {
                          deleteViewModelNotifier.toggleChatSelection(chat.id);
                        } else {
                          ref.read(messageViewModelProvider(chat.id));
                          navigatorKey.currentState!.push(MaterialPageRoute(
                              builder: (context) => ChatView(
                                    chatId: chat.id,
                                    deviceId: chat.deviceId,
                                    sendMessage: sendMessage,
                                    name: chat.chatName,
                                  )));
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          isSelecting = true;
                        });
                        deleteViewModelNotifier.toggleChatSelection(chat.id);
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigatorKey.currentState!.pushNamed(RoutesName.searchView);
        },
        backgroundColor: primaryBlack,
        child: const Icon(
          CupertinoIcons.search,
          color: Colors.white,
        ),
      ),
    );
  }

  final Strategy strategy = Strategy.P2P_STAR;
  List<String> connectedDevices = [];
  List<DiscoveredDevice> discoveredDevices = [];
  bool isConnected = false;
  String connectedEndpointId = '';
  bool isAdvertising = false;
  bool isDiscovering = false;
  Future<void> startAdvertising() async {
    Nearby().stopAllEndpoints();
    setState(() {
      isAdvertising = true;
    });
    final name = await ref.read(continueViewModelProvider.future);
    try {
      await Nearby().startAdvertising(
        name.name!,
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (String endpointId, Payload payload) async {
              String parentDir = (await getExternalStorageDirectory())!.absolute.path;

              if (payload.type == PayloadType.BYTES) {
                String str = String.fromCharCodes(payload.bytes!);

                // Check if this is an acknowledgment (ACK)
                if (str.startsWith("ACK:")) {
                  // This is an ACK, extract messageId
                  String ackMessageId = str.split(':')[1];
                  final chatId = await ref.read(chatViewModelProvider.notifier).getChatId(info.endpointName);
                  // Update the 'isSent' status in the database
                  ref.read(messageViewModelProvider(chatId!).notifier).updateMessageStatus(ackMessageId, true);
                  print("Received ACK for messageId: $ackMessageId, updated isSent in database.");
                  return;
                } else if (str.contains(':')) {
                  // This is a regular message (not an ACK)
                  List<String> parts = str.split(':');
                  String content = parts[0];
                  String messageId = parts[1]; // Extract messageId from the payload

                  // Save the message to the database
                  final chatId = await ref.read(chatViewModelProvider.notifier).getChatId(info.endpointName);
                  final MessageModel message = MessageModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: content,
                    senderId: endpointId,
                    senderName: name.name!,
                    timestamp: DateTime.now(),
                    isSender: false,
                    isDocument: false,
                    isSent: true,
                  );

                  ref.read(messageViewModelProvider(chatId!).notifier).addMessage(message, chatId);
                  print("Received and saved message: $content from $endpointId");

                  // Send an acknowledgment with the same messageId
                  await Nearby().sendBytesPayload(endpointId, Uint8List.fromList("ACK:$messageId".codeUnits)); // Send acknowledgment
                  print("Sent acknowledgment for messageId: $messageId");
                } else {
                  // Handle other cases, e.g., file transfer or malformed messages
                }
              } else if (payload.type == PayloadType.FILE) {
                // Handle file payload
                tempFileUri = payload.uri;
              }
            },
            onPayloadTransferUpdate: (String endpointId, PayloadTransferUpdate update) async {
              String parentDir = (await getExternalStorageDirectory())!.absolute.path;

              if (update.status == PayloadStatus.IN_PROGRESS) {
                print("Bytes Transferred: ${update.bytesTransferred}");
              } else if (update.status == PayloadStatus.FAILURE) {
                print("File transfer failed");
                // Optionally showSnackbar("$endpointId: Failed to transfer file");
              } else if (update.status == PayloadStatus.SUCCESS) {
                print("Transfer successful. Total bytes = ${update.totalBytes}");

                if (map.containsKey(update.id)) {
                  // Move file to the final location after successful transfer
                  String fileName = map[update.id]!;
                  moveFile(tempFileUri!, fileName).then((isMoved) async {
                    if (isMoved) {
                      String filePath = '$parentDir/$fileName';

                      // Fetch chatId
                      final chatId = await ref.read(chatViewModelProvider.notifier).getChatId(info.endpointName);

                      // Create a message with the file path and set isDocument to true
                      final MessageModel fileMessage = MessageModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: filePath,
                        senderId: endpointId,
                        senderName: name.name!,
                        timestamp: DateTime.now(),
                        isSender: false,
                        isDocument: true,
                        isSent: true,
                      );

                      // Add the file message to the message view model
                      ref.read(messageViewModelProvider(chatId!).notifier).addMessage(fileMessage, chatId);
                      print("Saved file message in database: $filePath");
                    } else {
                      print("Failed to move file");
                      // Optionally showSnackbar("Failed to move file");
                    }
                  });
                } else {
                  map[update.id] = "";
                }
              }
            },

          ).then((v) async {
            // Connection accepted, now checking for unsent messages
            // Fetch unsent messages from the local database
            List<Map<String, dynamic>> unsentMessages = await ref
                .read(chatViewModelProvider.notifier)
                .fetchUnsentMessages(info.endpointName);

            // Loop through each unsent message and send it
            for (var message in unsentMessages) {
              String messageId = message['id'].toString();
              String messageText = message['text'].toString();
              bool isDocument = message['isDocument'] == 1;

              // Use your existing sendMessage function to send the message
              if (isDocument) {
                // Send the message as a file using sendMessage
                sendMessage(messageText, messageId, true);
              } else {
                // Send the message as text using sendMessage
                sendMessage(messageText, messageId, false);
              }

              // Mark the message as sent in the database
            }

            print('All unsent messages have been processed and sent.');
          });

          setState(() {
            connectedDevices.add(id);
            connectedEndpointId = id;
            isConnected = true;
          });
          final chat = Chat(
              id: DateTime.now().millisecondsSinceEpoch,
              chatName: info.endpointName,
              createdAt: DateTime.timestamp(),
              deviceId: id);
          ref
              .read(homeViewModelProvider.notifier)
              .addChat(chat)
              .then((returnedId) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                  builder: (context) => ChatView(
                        name: info.endpointName,
                        chatId: returnedId!,
                        sendMessage: sendMessage,
                        deviceId: id,
                        isConnected: true,
                        connectedDevices: connectedDevices,
                      )),
            );
          });
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            setState(() {
              connectedDevices.add(id);
              isConnected = true;
            });
          }
        },
        onDisconnected: (String id) {
          setState(() {
            connectedDevices.remove(id);
            isConnected = false;
          });
        },
      );
      print("Advertising started.");
    } catch (e) {
      setState(() {
        isAdvertising = false;
      });
      print("Error starting advertising: $e");
    }
  }

  // Send Message to Connected Device
  void sendMessage(String message, String messageId, bool isDocument) async {
    final uniqueDevices = connectedDevices.toSet().toList();
    if (isConnected) {
      for (var device in uniqueDevices) {
        if (isDocument) {
          // Sending a file
          int payloadId = await Nearby().sendFilePayload(device, message);
          await Nearby().sendBytesPayload(
              device,
              Uint8List.fromList(
                  "$payloadId:${message.split('/').last}:$messageId"
                      .codeUnits));
        } else {
          // Sending a simple text message
          await Nearby().sendBytesPayload(
            device,
            Uint8List.fromList("$message:$messageId".codeUnits),
          );
          print("Sent message: $message with messageId: $messageId to $device");
        }
      }
    } else {
      print("No device is connected. Cannot send message.");
    }
  }

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');
    return b;
  }
}
