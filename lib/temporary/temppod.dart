// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:linkup/features/chat/repo/dbrepo.dart';
// import 'package:linkup/temporary/temp.dart';
// import 'package:nearby_connections/nearby_connections.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import '../features/chat/model/chat_model.dart';
// import '../features/chat/viewmodel/message_viewmodel.dart';
// import '../features/continue/viewModel/ContinueViewModel.dart';
// import '../features/home/viewmodel/home_viewmodel.dart';
// import '../main.dart';
// part 'temppod.g.dart';
//
// @riverpod
// class TempViewModel extends _$TempViewModel {
//   final Strategy strategy = Strategy.P2P_STAR;
//
//   @override
//   ChatState build() {
//     return ChatState();
//   }
//
//   // Forcefully disconnect all devices
//   Future<void> disconnectDevice(BluetoothDevice device) async {
//     try {
//       await device.disconnect();
//     } catch (e) {
//       print('Error disconnecting: $e');
//     }
//   }
//
//   Future<void> disconnectAllDevices() async {
//     List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
//     for (var device in connectedDevices) {
//       await disconnectDevice(device);
//     }
//   }
//
//   Future<void> startAdvertising(BuildContext context) async {
//     state = state.copyWith(isAdvertising: true);
//     final name = await ref.read(continueViewModelProvider.future);
//     print('Starting advertising with name: ${name.name}');
//     try {
//       await Nearby().startAdvertising(
//         name.name!,
//         strategy,
//         onConnectionInitiated: (String id, ConnectionInfo info) {
//           state = state.copyWith(
//             endpointName: info.endpointName,
//             connectedEndpointId: id,
//           );
//           Nearby().acceptConnection(id,
//               onPayLoadRecieved: (String endpointId, Payload payload) async {
//             String receivedMessage = String.fromCharCodes(payload.bytes!);
//             print(receivedMessage);
//             sendMessage(receivedMessage, id, types.User(id: info.endpointName));
//           });
//
//           state = state.copyWith(
//             connectedDevices: [...state.connectedDevices, id],
//             isConnected: true,
//           );
//         },
//         onConnectionResult: (String id, Status status) {
//           if (status == Status.CONNECTED) {
//             navigateFunction(context, state.endpointName, id);
//           } else {
//             print('Connection failed with status: $status');
//           }
//         },
//         onDisconnected: (String id) {
//           state = state.copyWith(
//             connectedDevices:
//                 state.connectedDevices.where((d) => d != id).toList(),
//             isConnected: false,
//           );
//         },
//       );
//     } on PlatformException catch (e) {
//       if (e.code == '8003') {
//         disconnectAllDevices();
//       } else {
//         print('Connection error: ${e.message}');
//       }
//     }
//   }
//
//   Future<void> startDiscovery(BuildContext context, fun) async {
//     Nearby().stopDiscovery();
//     state = state.copyWith(isDiscovering: true);
//     final name = await ref.read(continueViewModelProvider.future);
//     try {
//       await Nearby().startDiscovery(
//         name.name!,
//         strategy,
//         onEndpointFound: (String id, String name, String serviceId) {
//           state = state.copyWith(
//             discoveredDevices: [
//               ...state.discoveredDevices,
//               DiscoveredDevice(id: id, name: name),
//             ],
//           );
//         },
//         onEndpointLost: (String? id) {
//           state = state.copyWith(
//             discoveredDevices:
//                 state.discoveredDevices.where((d) => d.id != id).toList(),
//           );
//         },
//       );
//     } catch (e) {
//       state = state.copyWith(isDiscovering: false);
//       print('Discovery error: $e');
//     }
//   }
//
//   void sendMessage(partialText, chatId, types.User user) async {
//     final text = partialText.text;
//     if (text.isNotEmpty) {
//       final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//       final message = types.TextMessage(
//         author: user,
//         id: messageId,
//         text: text,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//       );
//       // Save message in SQLite and send via Bluetooth
//       ref
//           .read(messageViewModelProvider(chatId).notifier)
//           .addMessage(message, chatId);
//       dynamic devices = state.connectedDevices;
//       devices = devices.toSet().toList();
//       for (var device in devices) {
//         await Nearby().sendBytesPayload(
//           device,
//           Uint8List.fromList(partialText.codeUnits),
//         );
//       }
//     }
//   }
//
//   void navigateFunction(BuildContext context, String name, String id) async {
//     if (name.isEmpty || id.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error: Missing name or endpoint. Cannot create chat.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } else {
//       final chatId = DateTime.now().millisecondsSinceEpoch;
//       final chat = Chat(
//         id: chatId,
//         chatName: name,
//         createdAt: DateTime.now(),
//         deviceId: id,
//       );
//       final username = await ref.watch(continueViewModelProvider.future);
//       ref.read(homeViewModelProvider.notifier).addChat(chat).then((_) {
//         navigatorKey.currentState!.push(MaterialPageRoute(
//           builder: (context) => ChatView(
//             name: username.name!,
//             chatId: chatId,
//             deviceId: id,
//             isConnected: true,
//             connectedDevices: state.connectedDevices,
//           ),
//         ));
//       });
//     }
//   }
//
//   void connectToDevice(String deviceId, BuildContext context) async {
//     final name = await ref.read(continueViewModelProvider.future);
//
//     print('Connecting to device: $deviceId with name: ${name.name}');
//     try {
//       Nearby().requestConnection(
//         name.name!,
//         deviceId,
//         onConnectionInitiated: (String id, ConnectionInfo info) {
//           state = state.copyWith(
//             endpointName: info.endpointName,
//             connectedEndpointId: id,
//           );
//
//           Nearby().acceptConnection(id,
//               onPayLoadRecieved: (String endpointId, Payload payload) {
//             String receivedMessage = String.fromCharCodes(payload.bytes!);
//             onMessageReceived(receivedMessage);
//           });
//
//           state = state.copyWith(
//             connectedDevices: [...state.connectedDevices, id],
//             isConnected: true,
//           );
//         },
//         onConnectionResult: (String id, Status status) {
//           if (status == Status.CONNECTED) {
//             navigateFunction(context, state.endpointName, id);
//           } else {
//             print('Connection failed with status: $status');
//             _reconnectToDevice(deviceId);
//           }
//         },
//         onDisconnected: (String id) {
//           state = state.copyWith(
//             connectedDevices:
//                 state.connectedDevices.where((d) => d != id).toList(),
//             isConnected: false,
//           );
//           _reconnectToDevice(deviceId);
//         },
//       );
//     } on PlatformException catch (e) {
//       print('Connection error: ${e.message}');
//     }
//   }
//
//   void _reconnectToDevice(String deviceId) {
//     Future.delayed(const Duration(seconds: 2), () {
//       // Attempt reconnection logic here
//     });
//   }
//
//   void onMessageReceived(String receivedText) async {
//     final chatId = await ChatDatabase().getChatIdByName(state.endpointName);
//     final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final message = types.TextMessage(
//       author: types.User(id: state.endpointName),
//       id: messageId,
//       text: receivedText,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//     );
//     ref
//         .read(messageViewModelProvider(chatId!).notifier)
//         .addMessage(message, chatId);
//   }
// }
//
// // ChatState definition with default values and immutability
// class ChatState {
//   final List<String> connectedDevices;
//   final String connectedEndpointId;
//   final bool isConnected;
//   final bool isAdvertising;
//   final bool isDiscovering;
//   final String endpointName;
//   final List<DiscoveredDevice> discoveredDevices;
//
//   ChatState({
//     this.connectedDevices = const [],
//     this.connectedEndpointId = '',
//     this.isConnected = false,
//     this.isAdvertising = false,
//     this.endpointName = '',
//     this.isDiscovering = false,
//     this.discoveredDevices = const [],
//   });
//
//   ChatState copyWith({
//     List<String>? connectedDevices,
//     String? connectedEndpointId,
//     bool? isConnected,
//     bool? isAdvertising,
//     bool? isDiscovering,
//     String? endpointName,
//     List<DiscoveredDevice>? discoveredDevices,
//   }) {
//     return ChatState(
//       connectedDevices: connectedDevices ?? this.connectedDevices,
//       connectedEndpointId: connectedEndpointId ?? this.connectedEndpointId,
//       isConnected: isConnected ?? this.isConnected,
//       isAdvertising: isAdvertising ?? this.isAdvertising,
//       isDiscovering: isDiscovering ?? this.isDiscovering,
//       endpointName: endpointName ?? this.endpointName,
//       discoveredDevices: discoveredDevices ?? this.discoveredDevices,
//     );
//   }
// }
//
// // Example usage in the UI
