import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/Components/AppListTile.dart';
import 'package:linkup/features/continue/model/ConitnueModel.dart';
import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
import 'package:linkup/utils/routes/routesName.dart';

import '../../../main.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return PopScope(
      canPop: false,
      child: Scaffold(
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
        body: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, i) {
              return AppListTile(
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.chatView);
                },
                title: "Atif",
                message: "Let's Try LinkUp!",
                time: "9/21",
              );
            }),
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
      ),
    );
  }
}
