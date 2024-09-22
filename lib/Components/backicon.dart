import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: () {
        Navigator.pop(context);
      },
      color: Color(0xff1a1a1a),
    );
  }
}
