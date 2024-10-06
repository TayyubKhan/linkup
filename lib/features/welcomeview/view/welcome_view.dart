import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linkup/Components/Button.dart';
import 'package:linkup/utils/routes/routesName.dart';

class WelcomeView extends StatefulWidget {
   WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
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
             Image(image: AssetImage("assets/welcome.png")),
            Gap(height * 0.02),
            Center(
                child: Text(
              "Welcome to LinkUp",
              style: Theme.of(context).textTheme.titleLarge,
            )),
            Center(
                child: Text(
              "Seamlessly connect and ChatModel with ease.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )),
            Gap(height * 0.02),
            AppButton(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.continueView);
              },
              title: "Continue",
            )
          ],
        ),
      ),
    );
  }
}
