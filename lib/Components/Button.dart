import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

   const AppButton({super.key, this.title='', this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height * 0.07,
        width: width * .4,
        decoration: BoxDecoration(
            color: primaryBlack, borderRadius: BorderRadius.circular(35)),
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}
