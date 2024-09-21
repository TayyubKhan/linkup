import 'package:flutter/material.dart';

class SettingListTile extends StatelessWidget {
  String title;
  SettingListTile({super.key, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:  Text(
        title,
        style: const TextStyle(fontFamily: 'pop', fontWeight: FontWeight.w800),
      ),
      trailing: Switch(value: true, onChanged: (value) {}),
    );
  }
}
