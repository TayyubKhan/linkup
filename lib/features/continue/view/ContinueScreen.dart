import 'package:linkup/Components/Button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../utils/routes/routesName.dart';

class ContinueView extends StatefulWidget {
  const ContinueView({super.key});

  @override
  State<ContinueView> createState() => _ContinueViewState();
}

class _ContinueViewState extends State<ContinueView> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(height * 0.1),
            Center(
              child:
                  Text('LinkUp', style: Theme.of(context).textTheme.titleLarge),
            ),
            Gap(height * 0.01),
            Center(
              child: Text('Connect. Chat. LinkUp!',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            Gap(height * 0.01),
            Form(
                child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.tag), hintText: "Name"),
                ),
              ],
            )),
            Gap(height * 0.03),
             AppButton(
              onTap: (){
                Navigator.pushNamed(context, RoutesName.homeView);
              },
              title: "Continue",
            )
          ],
        ),
      ),
    );
  }
}
