import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
import 'package:linkup/main.dart';
import 'package:lottie/lottie.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import '../../../Components/backicon.dart';
import '../../../common_viewmodel/nearbycommunicationviewmodel.dart';
import '../../../utils/colors.dart';
import '../../chat/model/chat_model.dart';
import '../../chat/model/message_model/message_model.dart';
import '../../chat/repo/dbrepo.dart';
import '../../chat/view/chat_view.dart';
import '../../chat/viewmodel/message_viewmodel.dart';
import '../../home/viewmodel/home_viewmodel.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final Strategy strategy = Strategy.P2P_STAR;
  List<String> connectedDevices = [];
  List<DiscoveredDevice> discoveredDevices = [];
  bool isConnected = false;
  String connectedEndpointId = '';
  bool isAdvertising = false;
  bool isDiscovering = false;
  bool isLoading = true;
  Map<int, String> map = {};
  String? tempFileUri; //reference to the file currently being transferred
  Future<void> startDiscovery() async {
    setState(() {
      isDiscovering = true;
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Nearby().stopDiscovery();
    final name = await ref.read(continueViewModelProvider.future);
    try {
      await Nearby().startDiscovery(
        name.name!,
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          setState(() {
            isLoading = false;
          });
          setState(() {
            discoveredDevices.add(DiscoveredDevice(id: id, name: name));
          });
        },
        onEndpointLost: (String? id) {
          setState(() {
            discoveredDevices.removeWhere((device) => device.id == id);
          });
        },
      );
      print("Discovery started.");
    } catch (e) {
      setState(() {
        isDiscovering = false;
      });
      print("Error starting discovery: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Search",
            style: TextStyle(color: primaryBlack),
          ),
          automaticallyImplyLeading: true,
          actions: [
            InkWell(
              onTap: startAdvertising,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.refresh,
                  color: primaryBlack,
                ),
              ),
            ),
            InkWell(
              onTap: !isDiscovering ? startDiscovery : stopDiscovery,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: switch (isDiscovering) {
                  true => Icon(
                      Icons.pause,
                      color: primaryBlack,
                    ),
                  false => Icon(
                      Icons.play_arrow_outlined,
                      color: primaryBlack,
                    ),
                },
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: Lottie.asset('assets/search.json'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Available Users',
                      style: theme.textTheme.bodySmall,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: discoveredDevices.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              Icons.phone_android_outlined,
                              color: primaryBlack,
                            ),
                            title: Text(discoveredDevices[index].name),
                            trailing: InkWell(
                              onTap: () {
                                connectToDevice(discoveredDevices[index].id,
                                    discoveredDevices[index].name);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: primaryBlack,
                                    borderRadius: BorderRadius.circular(35)),
                                padding: const EdgeInsets.all(10),
                                child: Text('Connect',
                                    style: TextStyle(
                                        color: primaryWhite, fontSize: 11)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ));
  }

  Future<void> stopDiscovery() async {
    setState(() {
      isLoading = false;
    });
    await Nearby().stopDiscovery();
    setState(() {
      isDiscovering = false;
      discoveredDevices = [];
    });
  }

  void connectToDevice(String deviceId, String username) async {
    Nearby().disconnectFromEndpoint(deviceId);
    final name = await ref.read(continueViewModelProvider.future);
    Nearby().requestConnection(
      name.name!,
      deviceId,
      onConnectionInitiated: (String id, ConnectionInfo info) async {
        Nearby().acceptConnection(
          id,
          onPayLoadRecieved: (String endpointId, Payload payload) async {
            String parentDir =
                (await getExternalStorageDirectory())!.absolute.path;

            if (payload.type == PayloadType.BYTES) {
              String str = String.fromCharCodes(payload.bytes!);
              if (str.startsWith("ACK:")) {
                // This is an ACK, extract messageId
                String ackMessageId = str.split(':')[1];
                final chatId = await ref
                    .read(chatViewModelProvider.notifier)
                    .getChatId(info.endpointName);
                // Update the 'isSent' status in the database
                ref
                    .read(messageViewModelProvider(chatId!).notifier)
                    .updateMessageStatus(ackMessageId, true);
                print(
                    "Received ACK for messageId: $ackMessageId, updated isSent in database.");
                return;
              } else if (str.contains(':')) {
                List<String> parts = str.split(':');

                // If it's a message payload
                if (parts.length == 2) {
                  String content = parts[0];
                  String messageId = parts[1]; // Extract messageId

                  // Save the message to the database
                  final chatId = await ref
                      .read(chatViewModelProvider.notifier)
                      .getChatId(info.endpointName);
                  final MessageModel message = MessageModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: content,
                    senderId: endpointId,
                    senderName: info.endpointName,
                    timestamp: DateTime.now(),
                    isSender: false,
                    isDocument: false,
                    isSent: true,
                  );

                  ref
                      .read(messageViewModelProvider(chatId!).notifier)
                      .addMessage(message, chatId);
                  print(
                      "Received and saved message: $content from $endpointId");

                  // Send acknowledgment with the same messageId
                  await Nearby().sendBytesPayload(endpointId,
                      Uint8List.fromList("ACK:$messageId".codeUnits));
                  print("Sent acknowledgment for messageId: $messageId");
                }
                // Handle file payloads (payloadId:filename:messageId)
                else if (parts.length == 3) {
                  int payloadId = int.parse(parts[0]);
                  String fileName = parts[1];
                  String messageId = parts[2]; // messageId for ACK

                  if (map.containsKey(payloadId)) {
                    if (tempFileUri != null) {
                      await moveFile(tempFileUri!,
                          fileName); // Move the file to the desired location

                      // Optionally save the file message to the database
                      final chatId = await ref
                          .read(chatViewModelProvider.notifier)
                          .getChatId(info.endpointName);
                      final MessageModel message = MessageModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: fileName, // or some other indicator for a file
                        senderId: endpointId,
                        senderName: info.endpointName,
                        timestamp: DateTime.timestamp(),
                        isSender: false,
                        isDocument: true,
                        isSent: true,
                      );
                      ref
                          .read(messageViewModelProvider(chatId!).notifier)
                          .addMessage(message, chatId);
                      // Send acknowledgment for file transfer
                      await Nearby().sendBytesPayload(endpointId,
                          Uint8List.fromList("ACK:$messageId".codeUnits));
                      print(
                          "Sent acknowledgment for file with messageId: $messageId");
                    } else {}
                  } else {
                    // If payloadId doesn't exist in the map, add it for later processing
                    map[payloadId] = fileName;
                  }
                }
              }
            } else if (payload.type == PayloadType.FILE) {
              tempFileUri = payload.uri;
            }
          },
          onPayloadTransferUpdate:
              (String endpointId, PayloadTransferUpdate update) async {
            String parentDir =
                (await getExternalStorageDirectory())!.absolute.path;

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
                    final chatId = await ref
                        .read(chatViewModelProvider.notifier)
                        .getChatId(info.endpointName);

                    // Create a message with the file path and set isDocument to true
                    final MessageModel fileMessage = MessageModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: filePath,
                      senderId: endpointId,
                      senderName: info.endpointName,
                      timestamp: DateTime.now(),
                      isSender: false,
                      isDocument: true,
                      isSent: true,
                    );

                    // Add the file message to the message view model
                    ref
                        .read(messageViewModelProvider(chatId!).notifier)
                        .addMessage(fileMessage, chatId);
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
          }
        });
        setState(() {
          connectedEndpointId = id;
          connectedDevices.add(id);
          isConnected = true;
        });
        final newChatId = DateTime.now()
            .millisecondsSinceEpoch; // Generate a new unique chatId
        final newChat = Chat(
          id: newChatId,
          chatName: info.endpointName,
          createdAt: DateTime.now(), // Current timestamp
          deviceId: deviceId, // Set the deviceId
        );
        ref
            .read(homeViewModelProvider.notifier)
            .addChat(newChat)
            .then((returnID) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => ChatView(
                name: username,
                chatId: returnID!,
                sendMessage: sendMessage,
                deviceId: deviceId,
                isConnected: true,
              ),
            ),
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
  }

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
              String parentDir =
                  (await getExternalStorageDirectory())!.absolute.path;

              if (payload.type == PayloadType.BYTES) {
                String str = String.fromCharCodes(payload.bytes!);
                if (str.startsWith("ACK:")) {
                  // This is an ACK, extract messageId
                  String ackMessageId = str.split(':')[1];
                  final chatId = await ref
                      .read(chatViewModelProvider.notifier)
                      .getChatId(info.endpointName);
                  // Update the 'isSent' status in the database
                  ref
                      .read(messageViewModelProvider(chatId!).notifier)
                      .updateMessageStatus(ackMessageId, true);
                  print(
                      "Received ACK for messageId: $ackMessageId, updated isSent in database.");
                  return;
                } else if (str.contains(':')) {
                  List<String> parts = str.split(':');

                  // If it's a message payload
                  if (parts.length == 2) {
                    String content = parts[0];
                    String messageId = parts[1]; // Extract messageId

                    // Save the message to the database
                    final chatId = await ref
                        .read(chatViewModelProvider.notifier)
                        .getChatId(info.endpointName);
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

                    ref
                        .read(messageViewModelProvider(chatId!).notifier)
                        .addMessage(message, chatId);
                    print(
                        "Received and saved message: $content from $endpointId");

                    // Send acknowledgment with the same messageId
                    await Nearby().sendBytesPayload(endpointId,
                        Uint8List.fromList("ACK:$messageId".codeUnits));
                    print("Sent acknowledgment for messageId: $messageId");
                  }
                  // Handle file payloads (payloadId:filename:messageId)
                  else if (parts.length == 3) {
                    int payloadId = int.parse(parts[0]);
                    String fileName = parts[1];
                    String messageId = parts[2]; // messageId for ACK

                    if (map.containsKey(payloadId)) {
                      if (tempFileUri != null) {
                        moveFile(tempFileUri!,
                            fileName); // Move the file to the desired location

                        // Optionally save the file message to the database
                        final chatId = await ref
                            .read(chatViewModelProvider.notifier)
                            .getChatId(info.endpointName);
                        final MessageModel message = MessageModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          text: fileName, // or some other indicator for a file
                          senderId: endpointId,
                          senderName: name.name!,
                          timestamp: DateTime.now(),
                          isSender: false,
                          isDocument: true,
                          isSent: true,
                        );

                        ref
                            .read(messageViewModelProvider(chatId!).notifier)
                            .addMessage(message, chatId);

                        // Send acknowledgment for file transfer
                        await Nearby().sendBytesPayload(endpointId,
                            Uint8List.fromList("ACK:$messageId".codeUnits));
                        print(
                            "Sent acknowledgment for file with messageId: $messageId");
                      } else {}
                    } else {
                      // If payloadId doesn't exist in the map, add it for later processing
                      map[payloadId] = fileName;
                    }
                  }
                }
              } else if (payload.type == PayloadType.FILE) {
                tempFileUri = payload.uri;
              }
            },
            onPayloadTransferUpdate:
                (String endpointId, PayloadTransferUpdate update) async {
              String parentDir =
                  (await getExternalStorageDirectory())!.absolute.path;

              if (update.status == PayloadStatus.IN_PROGRESS) {
                print("Bytes Transferred: ${update.bytesTransferred}");
              } else if (update.status == PayloadStatus.FAILURE) {
                print("File transfer failed");
                // Optionally showSnackbar("$endpointId: Failed to transfer file");
              } else if (update.status == PayloadStatus.SUCCESS) {
                print(
                    "Transfer successful. Total bytes = ${update.totalBytes}");

                if (map.containsKey(update.id)) {
                  // Move file to the final location after successful transfer
                  String fileName = map[update.id]!;
                  moveFile(tempFileUri!, fileName).then((isMoved) async {
                    if (isMoved) {
                      String filePath = '$parentDir/$fileName';

                      // Fetch chatId
                      final chatId = await ref
                          .read(chatViewModelProvider.notifier)
                          .getChatId(info.endpointName);

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
                      ref
                          .read(messageViewModelProvider(chatId!).notifier)
                          .addMessage(fileMessage, chatId);
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

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');
    return b;
  }
}
