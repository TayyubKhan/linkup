
import 'package:flutter/material.dart';
import 'package:linkup/Components/AppListTile.dart';
import 'package:linkup/Components/settingListTile.dart';

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
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
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
            widget: Text(
              'Tayyub',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SettingListTile(
            title: "Notifications",
            widget: Switch(value: true, onChanged: (v) {}),
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
