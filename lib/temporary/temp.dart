// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:linkup/temporary/temppod.dart';
// import 'package:nearby_connections/nearby_connections.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:location/location.dart';
// import 'dart:developer';
// import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';
// import '../../../Components/backicon.dart';
// import '../../../utils/colors.dart';
// import '../features/chat/model/chat_model.dart';
// import '../features/chat/repo/dbrepo.dart';
// import '../features/chat/viewmodel/message_viewmodel.dart';
// import '../features/home/viewmodel/home_viewmodel.dart';
// import '../main.dart';
//
// class NearbyCommunicationScreen extends ConsumerStatefulWidget {
//   const NearbyCommunicationScreen({super.key});
//
//   @override
//   _NearbyCommunicationScreenState createState() =>
//       _NearbyCommunicationScreenState();
// }
//
// class _NearbyCommunicationScreenState
//     extends ConsumerState<NearbyCommunicationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     permission();
//   }
//
//   Future<void> permission() async {
//     // Request location permission
//     await Permission.location.request();
//     await Location.instance.requestService();
//
//     // Request external storage permission
//     await Permission.storage.request();
//     await Permission.ignoreBatteryOptimizations.request();
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Nearby Communication"),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: () async {
//               await Nearby().stopAllEndpoints();
//               ref
//                   .read(tempViewModelProvider.notifier)
//                   .startAdvertising(context);
//               Future.delayed(const Duration(seconds: 1));
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const DiscoverScreen()));
//             },
//             child: const Text('Start Discovering'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DiscoverScreen extends ConsumerStatefulWidget {
//   const DiscoverScreen({super.key});
//
//   @override
//   ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
// }
//
// class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
//   final Strategy strategy = Strategy.P2P_STAR;
//   List<String> connectedDevices = [];
//   List<DiscoveredDevice> discoveredDevices = [];
//   bool isConnected = false;
//   String connectedEndpointId = '';
//   bool isAdvertising = false;
//   bool isDiscovering = false;
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
//             onPressed: () async {
//               final username =
//                   await ref.watch(continueViewModelProvider.future);
//               !ref.read(tempViewModelProvider).isDiscovering
//                   ? ref
//                       .read(tempViewModelProvider.notifier)
//                       .startDiscovery(context, () async {
//                       final name = ref.read(tempViewModelProvider);
//                       final chatId = DateTime.now().millisecondsSinceEpoch;
//                       final chat = Chat(
//                         id: chatId,
//                         chatName: name.endpointName,
//                         createdAt: DateTime.now(),
//                         deviceId:
//                             ref.read(tempViewModelProvider).connectedEndpointId,
//                       );
//                       ref
//                           .read(homeViewModelProvider.notifier)
//                           .addChat(chat)
//                           .then((v) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChatView(
//                               name: username.name!,
//                               chatId: chatId,
//                               deviceId: ref
//                                   .read(tempViewModelProvider)
//                                   .connectedEndpointId,
//                               isConnected: true,
//                               connectedDevices: ref
//                                   .read(tempViewModelProvider)
//                                   .connectedDevices,
//                             ),
//                           ),
//                         );
//                       });
//                     })
//                   : null;
//             },
//             child: const Text('Start Discovering'),
//           ),
//           Expanded(
//             child: Consumer(
//               builder: (BuildContext context, WidgetRef ref, Widget? child) {
//                 final value = ref.watch(tempViewModelProvider);
//                 return ListView.builder(
//                   itemCount: value.discoveredDevices.length,
//                   itemBuilder: (context, index) {
//                     final devices = value.discoveredDevices;
//                     return ListTile(
//                       title: Text(devices[index].name),
//                       onTap: () {
//                         ref
//                             .read(tempViewModelProvider.notifier)
//                             .connectToDevice(devices[index].id, context);
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ChatView extends ConsumerStatefulWidget {
//   final int chatId;
//   final String deviceId; // chatId is the same as deviceId
//   bool isConnected;
//   final String name;
//   List<String> connectedDevices;
//   ChatView(
//       {super.key,
//       required this.chatId,
//       required this.deviceId,
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
//   types.User? user;
//   bool isEmojiVisible = false;
//   @override
//   bool get wantKeepAlive => true; // Keep the state alive
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref
//           .read(tempViewModelProvider)
//           .copyWith(connectedDevices: widget.connectedDevices);
//     });
//     user = types.User(id: widget.name, firstName: widget.name);
//     final tempViewModel = ref.watch(tempViewModelProvider);
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
//         title: Row(
//           children: [
//             InkWell(
//               onTap: () async {
//                 final endpoint = ref.read(tempViewModelProvider);
//                 Nearby().disconnectFromEndpoint(endpoint.connectedEndpointId);
//                 await ref.read(tempViewModelProvider.notifier).startDiscovery(
//                     context,
//                     showModalBottomSheet(
//                       context: context,
//                       builder: (builder) {
//                         return Consumer(
//                           builder: (context, ref, _) {
//                             return Center(
//                                 child: ListView.builder(
//                               itemCount: tempViewModel.discoveredDevices.length,
//                               itemBuilder: (context, index) {
//                                 final uniqueDevices = tempViewModel
//                                     .discoveredDevices
//                                     .toSet()
//                                     .toList();
//                                 return ListTile(
//                                   title: Text(uniqueDevices[index].name),
//                                   onTap: () {
//                                     ref
//                                         .read(tempViewModelProvider.notifier)
//                                         .connectToDevice(
//                                             uniqueDevices[index].id, context);
//                                     ref
//                                         .read(tempViewModelProvider)
//                                         .copyWith(isConnected: true);
//                                     Navigator.pop(context);
//                                   },
//                                 );
//                               },
//                             ));
//                           },
//                         );
//                       },
//                     ));
//               },
//               child: Icon(
//                 widget.isConnected
//                     ? Icons.bluetooth_connected
//                     : Icons.bluetooth_disabled,
//                 color: widget.isConnected ? Colors.green : Colors.red,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Chat',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert, color: primaryBlack),
//             onPressed: () async {
//               final value =ref.read(tempViewModelProvider);
//               print(value.connectedDevices);
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
//             onSendPressed: (text) async {
//               final name = await ref.read(continueViewModelProvider.future);
//               ref
//                   .read(tempViewModelProvider.notifier)
//                   .sendMessage(text, widget.chatId, types.User(id: name.name!));
//             },
//             user: user!,
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
//             onPressed: () async {
//               final name = await ref.read(continueViewModelProvider.future);
//               final user = types.User(id: name.name!, firstName: name.name);
//               ref.read(tempViewModelProvider.notifier).sendMessage(
//                   types.PartialText(text: _controller.text),
//                   widget.chatId,
//                   user);
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
//
// // Model for Discovered Device
// class DiscoveredDevice {
//   final String id;
//   final String name;
//
//   DiscoveredDevice({required this.id, required this.name});
// }
