import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SettingListTile extends StatelessWidget {
  String title;
  Widget widget;
  SettingListTile({super.key, this.title = '', this.widget = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontFamily: 'pop', fontWeight: FontWeight.w800),
      ),
      trailing: widget,
    );
  }
}
