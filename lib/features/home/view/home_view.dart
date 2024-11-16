import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
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
import '../../../core/repository/connection_repository.dart';
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
  final connectionRepo = GetIt.I<ConnectionRepositoryImplementation>();

  @override
  void initState() {
    super.initState();
    permission();
    Future.microtask(
        () => ref.read(homeViewModelProvider.notifier).loadChats());
    connectionRepo.startAdvertising();
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (v,k){
setState(() {
  isSelecting=false;

});      },
      child: Scaffold(
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
                                      sendMessage: connectionRepo.sendMessage,
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
      ),
    );
  }
}
