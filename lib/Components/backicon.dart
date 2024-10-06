import 'package:flutter/material.dart';

import '../utils/colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: () {
        Navigator.pop(context);
      },
      color: primaryBlack,
    );
  }
}
