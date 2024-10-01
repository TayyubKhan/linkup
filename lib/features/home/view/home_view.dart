import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/features/chat/view/chat_view.dart';
import 'package:linkup/features/chat/viewmodel/message_viewmodel.dart';
import 'package:linkup/features/home/viewmodel/home_viewmodel.dart';
import 'package:linkup/main.dart';
import '../../../utils/routes/routesName.dart';
import '../../chat/model/chat_model.dart';
import '../../chat/repo/dbrepo.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(homeViewModelProvider.notifier).loadChats());
  }

  @override
  Widget build(BuildContext context) {
    final chatList = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("LinkUp", style: Theme.of(context).textTheme.titleLarge),
        automaticallyImplyLeading: false,
        actions: [
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
                  return Dismissible(
                    key: Key(chat.id.toString()),
                    onDismissed: (_) {
                      ref
                          .read(homeViewModelProvider.notifier)
                          .deleteChat(chat.id);
                    },
                    background: Container(color: Colors.red),
                    child: ListTile(
                      title: Text(chat.chatName),
                      subtitle: Text('Created at: ${chat.createdAt}'),
                      onTap: () async {
                        ref.read(messageViewModelProvider(chat.id));
                        navigatorKey.currentState!.push(MaterialPageRoute(
                            builder: (context) => ChatView(
                                  chatId: chat.id,
                                )));
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
        backgroundColor: const Color(0xff1a1a1a),
        child: const Icon(
          CupertinoIcons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
// ref.read(homeViewModelProvider.notifier).addChat(newChat);