// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:linkup/temporary/temppod.dart';
// import 'package:nearby_connections/nearby_connections.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:location/location.dart';
// import 'dart:developer';
//
// import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';
// import '../../../Components/backicon.dart';
// import '../../../utils/colors.dart';
// import '../features/chat/model/chat_model.dart';
// import '../features/chat/viewmodel/chat_viewmodel.dart';
// import '../features/chat/viewmodel/message_viewmodel.dart';
// import '../features/home/viewmodel/home_viewmodel.dart';
// import '../main.dart';
//
// class NearbyCommunicationScreen extends ConsumerStatefulWidget {
//   @override
//   _NearbyCommunicationScreenState createState() =>
//       _NearbyCommunicationScreenState();
// }
//
// class _NearbyCommunicationScreenState
//     extends ConsumerState<NearbyCommunicationScreen> {
//   final Strategy strategy = Strategy.P2P_STAR;
//   List<String> connectedDevices = [];
//   List<DiscoveredDevice> discoveredDevices = [];
//   bool isConnected = false;
//   String connectedEndpointId = '';
//   bool isAdvertising = false;
//   bool isDiscovering = false;
//
//   @override
//   void initState() {
//     super.initState();
//     permission();
//     startAdvertising();
//   }
//
//   Future<void> permission() async {
//     // Request location permission
//     await Permission.location.request();
//     await Location.instance.requestService();
//
//     // Request external storage permission
//     await Permission.storage.request();
//
//     // Request Bluetooth permissions
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothAdvertise,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//     ].request();
//
//     // Android 12+
//     await Permission.nearbyWifiDevices.request();
//   }
//
//   Future<void> startAdvertising() async {
//     Nearby().stopAllEndpoints();
//     setState(() {
//       isAdvertising = true;
//     });
//     final name = await ref.read(continueViewModelProvider.future);
//     try {
//       final chatId = DateTime.now().millisecondsSinceEpoch;
//
//       await Nearby().startAdvertising(
//         name.name!,
//         strategy,
//         onConnectionInitiated: (String id, ConnectionInfo info) {
//           Nearby().acceptConnection(id,
//               onPayLoadRecieved: (String endpointId, Payload payload) {
//             String receivedMessage = String.fromCharCodes(payload.bytes!);
//             ref.read(messageViewModelProvider(chatId).notifier).addMessage(
//                 types.TextMessage(
//                   author: const types.User(id: '2nd'),
//                   id: DateTime.now().millisecondsSinceEpoch.toString(),
//                   type: types.MessageType.text,
//                   text: receivedMessage,
//                 ),
//                 chatId);
//           });
//
//           setState(() {
//             connectedDevices.add(id);
//             connectedEndpointId = id;
//             isConnected = true;
//           });
//           final chat = Chat(
//               id: chatId,
//               chatName: info.endpointName,
//               createdAt: DateTime.timestamp(),
//               deviceId: id);
//           ref.read(homeViewModelProvider.notifier).addChat(chat).then((v) {
//             navigatorKey.currentState!.push(
//               MaterialPageRoute(
//                   builder: (context) => ChatView(
//                         name: info.endpointName,
//                         chatId: chatId,
//                         sendMessage: sendMessage,
//                         deviceId: id,
//                         isConnected: true,
//                         connectedDevices: connectedDevices,
//                       )),
//             );
//           });
//         },
//         onConnectionResult: (String id, Status status) {
//           if (status == Status.CONNECTED) {
//             setState(() {
//               connectedDevices.add(id);
//               isConnected = true;
//             });
//           }
//         },
//         onDisconnected: (String id) {
//           setState(() {
//             connectedDevices.remove(id);
//             isConnected = false;
//           });
//         },
//       );
//       print("Advertising started.");
//     } catch (e) {
//       setState(() {
//         isAdvertising = false;
//       });
//       print("Error starting advertising: $e");
//     }
//   }
//
//   Future<void> startDiscovery() async {
//     Nearby().stopAllEndpoints();
//
//     setState(() {
//       isDiscovering = true;
//     });
//
//     try {
//       await Nearby().startDiscovery(
//         'abc',
//         strategy,
//         onEndpointFound: (String id, String name, String serviceId) {
//           setState(() {
//             discoveredDevices.add(DiscoveredDevice(id: id, name: name));
//           });
//         },
//         onEndpointLost: (String? id) {
//           setState(() {
//             discoveredDevices.removeWhere((device) => device.id == id);
//           });
//         },
//       );
//       print("Discovery started.");
//     } catch (e) {
//       setState(() {
//         isDiscovering = false;
//       });
//       print("Error starting discovery: $e");
//     }
//   }
//
//   // Send Message to Connected Device
//   void sendMessage(String message) async {
//     if (isConnected) {
//       for (var device in connectedDevices) {
//         await Nearby().sendBytesPayload(
//           device,
//           Uint8List.fromList(message.codeUnits),
//         );
//         print("Sent message: $message to $device");
//       }
//     } else {
//       print("No device is connected. Cannot send message.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Nearby Communication"),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const SearchScreen()));
//             },
//             child: const Text('Start Discovering'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Connect to a discovered device
//   void connectToDevice(String deviceId) async {
//     Nearby().disconnectFromEndpoint(deviceId);
//     final name = await ref.read(continueViewModelProvider.future);
//     Nearby().requestConnection(
//       'abc',
//       deviceId,
//       onConnectionInitiated: (String id, ConnectionInfo info) {
//         final chatId = DateTime.now().millisecondsSinceEpoch;
//         Nearby().acceptConnection(id,
//             onPayLoadRecieved: (String endpointId, Payload payload) {
//           String receivedMessage = String.fromCharCodes(payload.bytes!);
//           ref.read(messageViewModelProvider(chatId).notifier).addMessage(
//               types.TextMessage(
//                   author: const types.User(id: '2nd'),
//                   id: DateTime.now().millisecondsSinceEpoch.toString(),
//                   type: types.MessageType.text,
//                   text: receivedMessage),
//               chatId);
//         });
//
//         setState(() {
//           connectedEndpointId = id;
//           connectedDevices.add(id);
//           isConnected = true;
//         });
//         final chat = Chat(
//           id: chatId,
//           chatName: info.endpointName,
//           createdAt: DateTime.timestamp(),
//           deviceId: id,
//         );
//         ref.read(homeViewModelProvider.notifier).addChat(chat).then((v) {
//           navigatorKey.currentState!.push(
//             MaterialPageRoute(
//                 builder: (context) => ChatView(
//                       name: info.endpointName,
//                       chatId: chatId,
//                       sendMessage: sendMessage,
//                       deviceId: id,
//                       isConnected: true,
//                       connectedDevices: connectedDevices,
//                     )),
//           );
//         });
//       },
//       onConnectionResult: (String id, Status status) {
//         if (status == Status.CONNECTED) {
//           setState(() {
//             connectedDevices.add(id);
//             isConnected = true;
//           });
//         }
//       },
//       onDisconnected: (String id) {
//         setState(() {
//           connectedDevices.remove(id);
//           isConnected = false;
//         });
//       },
//     );
//   }
// }
//
// class SearchScreen extends ConsumerStatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   ConsumerState<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends ConsumerState<SearchScreen> {
//   final Strategy strategy = Strategy.P2P_STAR;
//   List<String> connectedDevices = [];
//   List<DiscoveredDevice> discoveredDevices = [];
//   bool isConnected = false;
//   String connectedEndpointId = '';
//   bool isAdvertising = false;
//   bool isDiscovering = false;
//
//   Future<void> startDiscovery() async {
//     Nearby().stopDiscovery();
//     setState(() {
//       isDiscovering = true;
//     });
//     final name = await ref.read(continueViewModelProvider.future);
//     try {
//       await Nearby().startDiscovery(
//         name.name!,
//         strategy,
//         onEndpointFound: (String id, String name, String serviceId) {
//           setState(() {
//             discoveredDevices.add(DiscoveredDevice(id: id, name: name));
//           });
//         },
//         onEndpointLost: (String? id) {
//           setState(() {
//             discoveredDevices.removeWhere((device) => device.id == id);
//           });
//         },
//       );
//       print("Discovery started.");
//     } catch (e) {
//       setState(() {
//         isDiscovering = false;
//       });
//       print("Error starting discovery: $e");
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     startDiscovery();
//   }
//
//   Future<void> stopDiscovery() async {
//     await Nearby().stopDiscovery();
//   }
//
//   void connectToDevice(String deviceId, String username) async {
//     Nearby().disconnectFromEndpoint(deviceId);
//     final name = await ref.read(continueViewModelProvider.future);
//     Nearby().requestConnection(
//       name.name!,
//       deviceId,
//       onConnectionInitiated: (String id, ConnectionInfo info) {
//         final chatId = DateTime.now().millisecondsSinceEpoch;
//         Nearby().acceptConnection(id,
//             onPayLoadRecieved: (String endpointId, Payload payload) {
//           String receivedMessage = String.fromCharCodes(payload.bytes!);
//           ref.read(messageViewModelProvider(chatId).notifier).addMessage(
//               types.TextMessage(
//                   author: const types.User(id: '2nd'),
//                   id: DateTime.now().millisecondsSinceEpoch.toString(),
//                   type: types.MessageType.text,
//                   text: receivedMessage),
//               chatId);
//         });
//
//         setState(() {
//           connectedEndpointId = id;
//           connectedDevices.add(id);
//           isConnected = true;
//         });
//         final chat = Chat(
//             id: chatId,
//             chatName: username,
//             createdAt: DateTime.timestamp(),
//             deviceId: id);
//         ref.read(homeViewModelProvider.notifier).addChat(chat).then((v) {
//           navigatorKey.currentState!.push(
//             MaterialPageRoute(
//                 builder: (context) => ChatView(
//                       name: username,
//                       chatId: chatId,
//                       sendMessage: sendMessage,
//                       deviceId: id,
//                       isConnected: true,
//                     )),
//           );
//         });
//       },
//       onConnectionResult: (String id, Status status) {
//         if (status == Status.CONNECTED) {
//           setState(() {
//             connectedDevices.add(id);
//             isConnected = true;
//           });
//         }
//       },
//       onDisconnected: (String id) {
//         setState(() {
//           connectedDevices.remove(id);
//           isConnected = false;
//         });
//       },
//     );
//   }
//
//   // Send Message to Connected Device
//   void sendMessage(String message) async {
//     if (isConnected) {
//       // Ensure devices are unique
//       final uniqueDevices = connectedDevices.toSet();
//
//       for (var device in uniqueDevices) {
//         await Nearby().sendBytesPayload(
//           device,
//           Uint8List.fromList(message.codeUnits),
//         );
//         print("Sent message: $message to $device");
//       }
//     } else {
//       print("No device is connected. Cannot send message.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: AppBackButton(),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           title: Text(
//             "Search",
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           automaticallyImplyLeading: true,
//           actions: [
//             InkWell(
//               onTap: !isDiscovering ? startDiscovery : stopDiscovery,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 10),
//                 child: switch (isDiscovering) {
//                   true => Icon(
//                       Icons.pause,
//                       color: primaryBlack,
//                     ),
//                   false => Icon(
//                       Icons.play_arrow_outlined,
//                       color: primaryBlack,
//                     ),
//                 },
//               ),
//             )
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 'Available Users',
//                 style: theme.textTheme.bodySmall,
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: discoveredDevices.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       leading: Icon(
//                         Icons.phone_android_outlined,
//                         color: primaryBlack,
//                       ),
//                       title: Text(discoveredDevices[index].name),
//                       onTap: () {
//                         connectToDevice(discoveredDevices[index].id,
//                             discoveredDevices[index].name);
//                       },
//                       trailing: Container(
//                         decoration: BoxDecoration(
//                             color: primaryBlack,
//                             borderRadius: BorderRadius.circular(35)),
//                         padding: const EdgeInsets.all(10),
//                         child: Text('Connect',
//                             style:
//                                 TextStyle(color: primaryWhite, fontSize: 11)),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }
// }
//
// // Model for Discovered Device
// class DiscoveredDevice {
//   final String id;
//   final String name;
//
//   DiscoveredDevice({required this.id, required this.name});
// }
//
// class ChatView extends ConsumerStatefulWidget {
//   final String name;
//   final int chatId;
//   final String deviceId; // chatId is the same as deviceId
//   final Function(String) sendMessage;
//   bool isConnected;
//   List<String> connectedDevices;
//   ChatView(
//       {super.key,
//       required this.chatId,
//       required this.deviceId,
//       required this.sendMessage,
//       required this.name,
//       this.isConnected = false,
//       this.connectedDevices = const []});
//
//   @override
//   ConsumerState<ChatView> createState() => _ChatViewState();
// }
//
// class _ChatViewState extends ConsumerState<ChatView>
//     with AutomaticKeepAliveClientMixin {
//   final TextEditingController _controller = TextEditingController();
//   final AutoScrollController _scrollController = AutoScrollController();
//   final _user = const types.User(id: 'user1'); // Represents the local user
//   bool isEmojiVisible = false;
//   @override
//   bool get wantKeepAlive => true; // Keep the state alive
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     connectedDevices.addAll(widget.connectedDevices);
//     widget.isConnected ? startAdvertising() : null;
//   }
//
//   List<String> connectedDevices = [];
//   final Strategy strategy = Strategy.P2P_STAR;
//   List<DiscoveredDevice> discoveredDevices = [];
//   String connectedEndpointId = '';
//   bool isAdvertising = false;
//   bool isDiscovering = false;
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Ensure the mixin works
//     // Watch the ChatViewModel state
//     final chatViewModel = ref.watch(tempViewModelProvider);
//     final messageController =
//         ref.watch(messageViewModelProvider(widget.chatId));
//     return Scaffold(
//       extendBodyBehindAppBar: false,
//       extendBody: false,
//       backgroundColor: primaryWhite,
//       appBar: AppBar(
//         leading: AppBackButton(),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           widget.name,
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert, color: primaryBlack),
//             onPressed: () async {
//               // Example action using the continueViewModelProvider
//               final name = await ref.read(continueViewModelProvider.future);
//               log(name.name!);
//             },
//           ),
//         ],
//         scrolledUnderElevation: 0,
//       ),
//       body: messageController.when(
//         data: (messages) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (_scrollController.hasClients) {
//               _scrollController
//                   .jumpTo(_scrollController.position.maxScrollExtent);
//             }
//           });
//           return chat.Chat(
//             messages: messages.reversed.toList(),
//             onSendPressed: _onSendPressed,
//             user: _user,
//             theme: chat.DefaultChatTheme(
//               inputBackgroundColor: primaryBlack,
//               inputTextColor: primaryWhite,
//             ),
//             customBottomWidget: _buildInputArea(),
//             scrollController: _scrollController,
//             scrollPhysics: const BouncingScrollPhysics(),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stackTrace) {
//           log('Error: $error');
//           log('StackTrace: $stackTrace');
//           return Center(child: Text('Error occurred: $error'));
//         },
//       ),
//     );
//   }
//
//   Future<void> startAdvertising() async {
//     Nearby().stopAdvertising();
//     setState(() {
//       isAdvertising = true;
//     });
//     final name = await ref.read(continueViewModelProvider.future);
//     try {
//       final chatId = DateTime.now().millisecondsSinceEpoch;
//
//       await Nearby().startAdvertising(
//         name.name!,
//         strategy,
//         onConnectionInitiated: (String id, ConnectionInfo info) {
//           Nearby().acceptConnection(id,
//               onPayLoadRecieved: (String endpointId, Payload payload) {
//             String receivedMessage = String.fromCharCodes(payload.bytes!);
//             ref.read(messageViewModelProvider(chatId).notifier).addMessage(
//                 types.TextMessage(
//                   author: const types.User(id: 'def'),
//                   id: DateTime.now().millisecondsSinceEpoch.toString(),
//                   type: types.MessageType.text,
//                   text: receivedMessage,
//                 ),
//                 chatId);
//           });
//           setState(() {
//             connectedDevices.add(id);
//             connectedEndpointId = id;
//             widget.isConnected = true;
//           });
//         },
//         onConnectionResult: (String id, Status status) {
//           if (status == Status.CONNECTED) {
//             setState(() {
//               connectedDevices.add(id);
//               widget.isConnected = true;
//             });
//           }
//         },
//         onDisconnected: (String id) {
//           setState(() {
//             connectedDevices.remove(id);
//             widget.isConnected = false;
//           });
//         },
//       );
//       print("Advertising started.");
//     } catch (e) {
//       setState(() {
//         isAdvertising = false;
//       });
//       print("Error starting advertising: $e");
//     }
//   }
//
//   Future<void> startDiscovery() async {
//     widget.isConnected ? startAdvertising() : null;
//     Nearby().stopDiscovery();
//     setState(() {
//       isDiscovering = true;
//     });
//     final name = await ref.read(continueViewModelProvider.future);
//     try {
//       await Nearby().startDiscovery(
//         name.name!,
//         strategy,
//         onEndpointFound: (String id, String name, String serviceId) {
//           setState(() {
//             discoveredDevices.add(DiscoveredDevice(id: id, name: name));
//           });
//           showModalBottomSheet(
//             context: context,
//             builder: (builder) {
//               return Center(
//                   child: ListView.builder(
//                 itemCount: discoveredDevices.length,
//                 itemBuilder: (context, index) {
//                   final uniqueDevices = discoveredDevices.toSet().toList();
//                   return ListTile(
//                     title: Text(uniqueDevices[index].name),
//                     onTap: () {
//                       connectToDevice(uniqueDevices[index].id);
//                       widget.isConnected = true;
//                       Navigator.pop(context);
//                     },
//                   );
//                 },
//               ));
//             },
//           );
//         },
//         onEndpointLost: (String? id) {
//           setState(() {
//             discoveredDevices.removeWhere((device) => device.id == id);
//             widget.isConnected = false;
//           });
//         },
//       );
//       print("Discovery started.");
//     } catch (e) {
//       setState(() {
//         isDiscovering = false;
//       });
//       print("Error starting discovery: $e");
//     }
//   }
//
//   void sendMessage(String message) async {
//     if (widget.isConnected) {
//       for (var device in connectedDevices) {
//         await Nearby().sendBytesPayload(
//           device,
//           Uint8List.fromList(message.codeUnits),
//         );
//         print("Sent message: $message to $device");
//       }
//     } else {
//       print("No device is connected. Cannot send message.");
//     }
//   }
//
//   // Method to handle sending a message
//   void _onSendPressed(types.PartialText partialText) async {
//     log(partialText.text);
//     final text = partialText.text;
//     if (text.isNotEmpty) {
//       final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//       final message = types.TextMessage(
//         author: _user,
//         id: messageId,
//         text: text,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//       );
//       // Save message in SQLite and send via Bluetooth
//       ref
//           .read(messageViewModelProvider(widget.chatId).notifier)
//           .addMessage(message, widget.chatId);
//       _controller.clear(); // Clear the input
//       // Add your method to send the message to the connected device
//     }
//   }
//
//   // Start listening for incoming messages and connect to the device
//   void connectToDevice(String deviceId) async {
//     Nearby().disconnectFromEndpoint(deviceId);
//     final name = await ref.read(continueViewModelProvider.future);
//     Nearby().requestConnection(
//       name.name!,
//       deviceId,
//       onConnectionInitiated: (String id, ConnectionInfo info) {
//         Nearby().acceptConnection(id,
//             onPayLoadRecieved: (String endpointId, Payload payload) {
//           String receivedMessage = String.fromCharCodes(payload.bytes!);
//           _onMessageReceived(receivedMessage);
//         });
//         setState(() {
//           connectedDevices.add(id);
//           widget.isConnected = true;
//         });
//       },
//       onConnectionResult: (String id, Status status) {
//         if (status == Status.CONNECTED) {
//           setState(() {
//             connectedDevices.add(id);
//             widget.isConnected = true;
//           });
//         } else {
//           // If the connection fails, attempt to reconnect
//         }
//       },
//       onDisconnected: (String id) {
//         setState(() {
//           connectedDevices.remove(id);
//           widget.isConnected = false;
//         });
//         // Attempt to reconnect when disconnected
//       },
//     );
//   }
//
//   // Handle the received message
//   void _onMessageReceived(String receivedText) {
//     final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final message = types.TextMessage(
//       author: types.User(
//           id: widget.chatId.toString()), // Author is the other device
//       id: messageId,
//       text: receivedText,
//       createdAt: int.parse(DateTime.now()
//           .millisecondsSinceEpoch
//           .toString()), // Corrected timestamp generation
//     );
//
//     // Save the received message in the database
//     ref
//         .read(messageViewModelProvider(widget.chatId).notifier)
//         .addMessage(message, widget.chatId);
//   }
//
//   // Build the input area
//   Widget _buildInputArea() {
//     return Container(
//       color: primaryBlack,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(isEmojiVisible ? Icons.keyboard : Icons.emoji_emotions),
//             onPressed: _toggleEmojiVisibility,
//             color: Colors.white,
//           ),
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 hintText: 'Type a message',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 border: InputBorder.none,
//               ),
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: () {
//               widget.sendMessage(_controller.text);
//               _onSendPressed(types.PartialText(text: _controller.text));
//             },
//             color: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Toggle emoji visibility (Optional)
//   void _toggleEmojiVisibility() {
//     setState(() {
//       isEmojiVisible = !isEmojiVisible;
//     });
//   }
// }
