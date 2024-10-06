import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/features/splash/viewmodel/splash_viewmodel.dart';
import 'package:linkup/main.dart';
import 'package:linkup/utils/routes/routesName.dart'; // Import for Riverpod

class SplashView extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
   SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  // Updated to ConsumerState
  @override
  void initState() {
    super.initState();
    Timer( Duration(seconds: 2), () {
      _check();
    });
  }

  void _check() async {
    final value = await ref.read(splashViewModelProvider.future);
    if (value) {
      navigatorKey.currentState!.pushNamed(RoutesName.homeView);
    } else {
      navigatorKey.currentState!.pushNamed(RoutesName.welcomeView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "LinkUp",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Gap(height * 0.02),
             Image(image: AssetImage("assets/welcome.png")),
          ],
        ),
      ),
    );
  }
}
