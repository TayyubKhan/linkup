import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/colors.dart';

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
        style:  TextStyle(fontFamily: 'pop', fontWeight: FontWeight.w800),
      ),
      leading:  CircleAvatar(
          backgroundColor: primaryBlack,
          child: Icon(
            Icons.person,
            color: primaryWhite,
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
            style:  TextStyle(fontFamily: 'pop', fontSize: 11),
          ),
          isOnline
              ? Container(
                  width: height * 0.01,
                  height: height * 0.01,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.18, color: primaryBlack),
                      shape: BoxShape.circle,
                      color: Colors.green),
                )
              :  SizedBox()
        ],
      ),
    );
  }
}
