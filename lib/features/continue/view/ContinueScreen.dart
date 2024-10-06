import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/Components/Button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
import 'package:linkup/main.dart';
import 'package:linkup/utils/routes/routesName.dart';

import '../../../temporary/temp.dart';

class ContinueView extends StatefulWidget {
  const ContinueView({super.key});

  @override
  State<ContinueView> createState() => _ContinueViewState();
}

class _ContinueViewState extends State<ContinueView> {
  final nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
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
              child: Text('Connect. ChatModel. LinkUp!',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            Gap(height * 0.01),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.tag), hintText: "Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name'; // Return error message if empty
                        }
                        return null; // Return null if validation passes
                      },
                    ),
                    Gap(height * 0.03),
                    Consumer(
                      builder: (context, ref, child) {
                        return AppButton(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(continueViewModelProvider.notifier)
                                  .setName(nameController.text.toString());
                              navigatorKey.currentState!
                                  .pushNamed(RoutesName.homeView);
                            }
                          },
                          title: "Continue",
                        );
                      },
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
