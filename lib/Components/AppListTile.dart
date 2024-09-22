import 'package:flutter/material.dart';

import '../main.dart';

class AppListTile extends StatelessWidget {
  String title;
  String message;
  String time;
  bool isOnline;
  int index;
  VoidCallback? onTap;
  AppListTile(
      {super.key,
      this.title = '',
      this.message = '',
      this.time = '',
      this.isOnline = true,
      this.index = 1,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'pop', fontWeight: FontWeight.w800),
      ),
      leading: const CircleAvatar(
          backgroundColor: Color(0xff1a1a1a),
          child: Icon(
            Icons.person,
            color: Color(0xffF7F7F7),
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
                      border: Border.all(width: 0.18, color: Color(0xff1a1a1a)),
                      shape: BoxShape.circle,
                      color: Colors.green),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
