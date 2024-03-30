import 'package:flutter/material.dart';

class IconButtonBig extends StatelessWidget {
  Color color;
  Icon icon;
  Function function;
  bool enabled;
  IconButtonBig({
    super.key,
    required this.color,
    required this.icon,
    required this.function,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: enabled
        ? Colors.white
        : Colors.white.withOpacity(0.2)
      ,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(enabled
            ? color
            : color.withOpacity(0.2)),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(24.6),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      onPressed: () => enabled
          ? function()
          : null,
      icon: icon,
    );
  }
}