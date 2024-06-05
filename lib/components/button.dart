import 'package:flutter/material.dart';

import '../style/constants.dart';

// Handy Multi-purpose Button Widget

class Button extends StatelessWidget {

  final Function()? onTap;
  final Widget widget;
  final Color color;

  const Button({super.key, required this.onTap, required this.widget, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
            child: widget
          ),
        ),
      ),
    );
  }
}