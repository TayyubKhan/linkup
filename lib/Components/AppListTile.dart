import 'package:flutter/material.dart';

import '../main.dart';

class AppListTile extends StatelessWidget {
  String title;
  String message;
  String time;
  bool isOnline;
  int index;
  AppListTile({
    super.key,
    this.title = '',
    this.message = '',
    this.time = '',
    this.isOnline = true,
    this.index = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'pop', fontWeight: FontWeight.w800),
      ),
      leading: const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(
            Icons.person,
            color: Colors.white,
          )),
      subtitle: Text(
        message,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(fontFamily: 'pop', fontSize: 11),
          ),
          isOnline
              ? const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 5,
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
