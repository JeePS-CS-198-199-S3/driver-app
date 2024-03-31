import 'package:flutter/material.dart';

class WidgetButtonBig extends StatelessWidget {
  Widget widget;
  Color color;
  Function function;
  bool enabled;
  bool isLong;
  WidgetButtonBig({
    super.key,
    required this.widget,
    required this.color,
    required this.function,
    required this.enabled,
    this.isLong = true
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => enabled && !isLong
        ? function()
        : null,
      onLongPress: () => enabled && isLong
        ? function()
        : null,
      child: Container(
        decoration: BoxDecoration(
            color: enabled? color:color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0)
        ),
        width: 73,
        height: 73,
        child: Opacity(
          opacity: enabled? 1:0.2,
          child: widget),
      ),
    );
  }
}
