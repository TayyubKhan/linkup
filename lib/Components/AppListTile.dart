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
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
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
              ? Container(
                  width: height * 0.01,
                  height: height * 0.01,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.7, color: Colors.black),
                      shape: BoxShape.circle,
                      color: Colors.green),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
