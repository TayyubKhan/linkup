import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/features/continue/model/ConitnueModel.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import '../../Viewmodel/connectionViewModel.dart';
import '../../features/chat/model/chat_model.dart';
import '../../features/chat/model/message_model/message_model.dart';
import '../../features/chat/view/chat_view.dart';
import '../../features/chat/viewmodel/chat_viewmodel.dart';
import '../../features/chat/viewmodel/message_viewmodel.dart';
import '../../features/continue/viewModel/ContinueViewModel.dart';
import '../../features/home/viewmodel/home_viewmodel.dart';
import '../../main.dart';
import '../../temporary/scan.dart';
import '../notificationRepo.dart';

sealed class ConnectionRepository {
  Future<void> startDiscovery() async {}

  Future<void> startAdvertising() async {}

  void connectDevice(String deviceId, String username) {}

  void requestConnection(
      ContinueModel name, String deviceId, String username) {}

  void acceptConnection(String id, ConnectionInfo info) {}

  void sendMessage(String message, String messageId, bool isDocument) {}

  Future<void> stopDiscovery() async {}

  Future<void> stopAdvertising() async {}

  Future<bool> moveFile(String uri, String fileName) async {
    return false;
  }
}

class ConnectionRepositoryImplementation implements ConnectionRepository {
  final Strategy strategy = Strategy.P2P_STAR;
  final WidgetRef ref;

  ConnectionRepositoryImplementation(this.ref);

  @override
  Future<void> startAdvertising() async {
    await Nearby().stopAllEndpoints();
    ref.read(isAdvertisingProvider.notifier).state = true;

    final name = await ref.read(continueViewModelProvider.future);
    try {
      await Nearby().startAdvertising(
        name.name!,
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) async {
          await acceptConnection(id, info);
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            List<String> connectedDevices = [
              ...ref.read(connectedDevicesProvider)
            ];
            connectedDevices.add(id);
            // ref.read(connectedDevicesProvider.notifier).state = connectedDevices;
            ref
                .read(connectedEndpointIdProvider.notifier)
                .update((state) => id);
            log(ref.read(connectedEndpointIdProvider).toString());
            ref.read(isConnectedProvider.notifier).state = true;
          }
        },
        onDisconnected: (String id) {
          List<String> connectedDevices = [
            ...ref.read(connectedDevicesProvider)
          ];
          connectedDevices.remove(id);
          ref.read(connectedDevicesProvider.notifier).state =
              connectedDevices.toSet().toList();
          ref.read(isConnectedProvider.notifier).state = false;
        },
      );
      print("Advertising started.");
    } catch (e) {
      ref.read(isAdvertisingProvider.notifier).state = false;
    }
  }

  @override
  Future<void> startDiscovery() async {
    ref.read(isDiscoveringProvider.notifier).state = true;
    ref.read(isLoadingProvider.notifier).state = true;
    await Future.delayed(const Duration(seconds: 1));
    Nearby().stopDiscovery();
    final name = await ref.read(continueViewModelProvider.future);
    try {
      await Nearby().startDiscovery(
        name.name!,
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          ref.read(isLoadingProvider.notifier).state = false;
          List<DiscoveredDevice> discoveredDevices = [
            ...ref.read(discoveredDevicesProvider)
          ];
          discoveredDevices.add(DiscoveredDevice(id: id, name: name));
          ref.read(discoveredDevicesProvider.notifier).state =
              discoveredDevices.toSet().toList();
        },
        onEndpointLost: (String? id) {
          List<DiscoveredDevice> discoveredDevices = [
            ...ref.read(discoveredDevicesProvider)
          ];
          discoveredDevices.removeWhere((device) => device.id == id);
          ref.read(discoveredDevicesProvider.notifier).state =
              discoveredDevices.toSet().toList();
        },
      );
    } catch (e) {
      ref.read(isDiscoveringProvider.notifier).state = false;
    }
  }

  @override
  Future<void> acceptConnection(String id, ConnectionInfo info) async {
    Map<int, String> map = {};
    String? tempFileUri;
    try {
      List<String> connectedDevices = [...ref.read(connectedDevicesProvider)];
      connectedDevices.add(id);
      ref.read(connectedDevicesProvider.notifier).state = connectedDevices;
      ref.read(connectedEndpointIdProvider.notifier).update((state) => id);
      log(ref.read(connectedEndpointIdProvider).toString());
      ref.read(isConnectedProvider.notifier).state = true;

      await Nearby().acceptConnection(
        id,
        onPayLoadRecieved: (String endpointId, Payload payload) async {
          if (payload.type == PayloadType.BYTES) {
            String str = String.fromCharCodes(payload.bytes!);
            if (str.startsWith("ACK:")) {
              String ackMessageId = str.split(':')[1];
              final chatId = await ref
                  .read(chatViewModelProvider.notifier)
                  .getChatId(info.endpointName);
              ref
                  .read(messageViewModelProvider(chatId!).notifier)
                  .updateMessageStatus(ackMessageId, true);
              return;
            } else if (str.contains(':')) {
              List<String> parts = str.split(':');

              if (parts.length == 2) {
                String content = parts[0];
                String messageId = parts[1];

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
                LocalNotificationService.showNotification(
                  0,
                  info.endpointName,
                  content,
                );
                await Nearby().sendBytesPayload(
                    endpointId, Uint8List.fromList("ACK:$messageId".codeUnits));
              } else if (parts.length == 3) {
                int payloadId = int.parse(parts[0]);
                String fileName = parts[1];
                String messageId = parts[2];

                if (map.containsKey(payloadId)) {
                  if (tempFileUri != null) {
                    moveFile(tempFileUri!, fileName);

                    final chatId = await ref
                        .read(chatViewModelProvider.notifier)
                        .getChatId(info.endpointName);
                    final MessageModel message = MessageModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: fileName,
                      senderId: endpointId,
                      senderName: info.endpointName,
                      timestamp: DateTime.now(),
                      isSender: false,
                      isDocument: true,
                      isSent: true,
                    );

                    ref
                        .read(messageViewModelProvider(chatId!).notifier)
                        .addMessage(message, chatId);

                    await Nearby().sendBytesPayload(endpointId,
                        Uint8List.fromList("ACK:$messageId".codeUnits));
                    LocalNotificationService.showNotification(
                      0,
                      info.endpointName,
                      fileName,
                    );
                  } else {}
                } else {
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
          } else if (update.status == PayloadStatus.SUCCESS) {
            print("Transfer successful. Total bytes = ${update.totalBytes}");

            if (map.containsKey(update.id)) {
              String fileName = map[update.id]!;
              moveFile(tempFileUri!, fileName).then((isMoved) async {
                if (isMoved) {
                  String filePath = '$parentDir/$fileName';

                  final chatId = await ref
                      .read(chatViewModelProvider.notifier)
                      .getChatId(info.endpointName);

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

                  ref
                      .read(messageViewModelProvider(chatId!).notifier)
                      .addMessage(fileMessage, chatId);
                  print("Saved file message in database: $filePath");
                } else {
                  print("Failed to move file");
                }
              });
            } else {
              map[update.id] = "";
            }
          }
        },
      ).then((v) async {
        List<Map<String, dynamic>> unsentMessages = await ref
            .read(chatViewModelProvider.notifier)
            .fetchUnsentMessages(info.endpointName);

        for (var message in unsentMessages) {
          String messageId = message['id'].toString();
          String messageText = message['text'].toString();
          bool isDocument = message['isDocument'] == 1;

          if (isDocument) {
            sendMessage(messageText, messageId, true);
          } else {
            sendMessage(messageText, messageId, false);
          }
        }
      });
      final newChatId = DateTime.now().millisecondsSinceEpoch;
      final newChat = Chat(
        id: newChatId,
        chatName: info.endpointName,
        createdAt: DateTime.now(),
        deviceId: id,
      );
      ref
          .read(homeViewModelProvider.notifier)
          .addChat(newChat)
          .then((returnID) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => ChatView(
              name: info.endpointName,
              chatId: returnID!,
              sendMessage: sendMessage,
              deviceId: id,
              isConnected: true,
            ),
          ),
        );
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void connectDevice(String deviceId, String username) async {
    Nearby().disconnectFromEndpoint(deviceId);
    final name = await ref.read(continueViewModelProvider.future);
    await requestConnection(name, deviceId, username);
  }

  @override
  Future<void> requestConnection(
      ContinueModel name, String deviceId, String username) async {
    await Nearby().requestConnection(
      name.name!,
      deviceId,
      onConnectionInitiated: (String id, ConnectionInfo info) async {
        await acceptConnection(id, info);
      },
      onConnectionResult: (String id, Status status) {
        if (status == Status.CONNECTED) {
          List<String> connectedDevices = [
            ...ref.read(connectedDevicesProvider)
          ];
          connectedDevices.add(id);
          ref.read(connectedDevicesProvider.notifier).state =
              connectedDevices.toSet().toList();
          ref.read(connectedEndpointIdProvider.notifier).update((state) => id);
          log(ref.read(connectedEndpointIdProvider).toString());
        }
      },
      onDisconnected: (String id) {
        List<String> connectedDevices = [...ref.read(connectedDevicesProvider)];
        connectedDevices.remove(id);
        ref.read(connectedDevicesProvider.notifier).state =
            connectedDevices.toSet().toList();
        ref.read(connectedEndpointIdProvider.notifier).state = 'Empty';
        ref.read(isConnectedProvider.notifier).state = false;
      },
    );
  }

  @override
  void sendMessage(String message, String messageId, bool isDocument) async {
    final uniqueDevices = ref.read(connectedDevicesProvider).toSet().toList();
    if (ref.read(isConnectedProvider)) {
      for (var device in uniqueDevices) {
        if (isDocument) {
          int payloadId = await Nearby().sendFilePayload(device, message);
          await Nearby().sendBytesPayload(
              device,
              Uint8List.fromList(
                  "$payloadId:${message.split('/').last}:$messageId"
                      .codeUnits));
        } else {
          await Nearby().sendBytesPayload(
            device,
            Uint8List.fromList("$message:$messageId".codeUnits),
          );
        }
      }
    } else {
    }
  }

  @override
  Future<void> stopAdvertising() async {
    ref.read(isAdvertisingProvider.notifier).state = false;
    await Nearby().stopAdvertising();
  }
  @override
  Future<void> stopDiscovery() async {
    ref.read(isDiscoveringProvider.notifier).state = false;
    ref.read(isLoadingProvider.notifier).state = false;
    await Nearby().stopAdvertising();
  }
  @override
  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');
    return b;
  }
}
