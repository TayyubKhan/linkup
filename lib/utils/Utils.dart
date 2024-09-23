import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';

class Utils {
  static appFlushBar(String message, BuildContext context) {
    return Flushbar(
      duration: const Duration(seconds: 3),
      message: message,
      title: "Error",
    )..show(context);
  }
}
