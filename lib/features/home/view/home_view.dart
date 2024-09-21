import 'package:flutter/material.dart';
import 'package:linkup/Components/AppListTile.dart';
import 'package:linkup/utils/routes/routesName.dart';

import '../../../main.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {  final height = MediaQuery.sizeOf(context).height;
  final width = MediaQuery.sizeOf(context).width;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "LinkUp",
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
        body: Column(
          children: [
            AppListTile(
              title: "Tayyub",
              message: "Let's Try LinkUp!",
              time: "9/21",
            )
          ],
        ),
      ),
    );
  }
}
