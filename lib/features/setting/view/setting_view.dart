import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/Components/AppListTile.dart';
import 'package:linkup/Components/settingListTile.dart';
import 'package:linkup/features/setting/viewmodel/setting_viewmodel.dart';

import '../../../Components/backicon.dart';
import '../../continue/viewModel/ContinueViewModel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Setting",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          SettingListTile(
            title: "Name",
            widget: Consumer(
              builder: (context, ref, child) {
                final value = ref.watch(continueViewModelProvider);
                return switch (value) {
                  AsyncData(:final value) => Text(
                      value.name!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  AsyncError() => Text(
                      'error',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  _ => Text(
                      'loading',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                };
              },
            ),
          ),
          SettingListTile(
            title: "Notifications",
            widget: Consumer(
              builder: (context, ref, child) {
                final switchValue = ref.watch(notificationSwitchProvider);
                return Switch(
                    value: switchValue,
                    onChanged: (v) {
                      ref
                          .read(notificationSwitchProvider.notifier)
                          .changeNotification();
                    });
              },
            ),
          ),
          SettingListTile(
            title: "Password",
            widget: Text(
              'Update',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }
}
