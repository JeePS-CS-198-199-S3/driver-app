import 'package:flutter/material.dart';

class WidgetButtonBig extends StatelessWidget {
  Widget widget;
  Color color;
  Function function;
  bool enabled;
  bool isLong;
  bool outLined;
  WidgetButtonBig({
    super.key,
    required this.widget,
    required this.color,
    required this.function,
    required this.enabled,
    this.isLong = true,
    this.outLined = false
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
            color: !outLined
              ? enabled
                ? color
                : color.withOpacity(0.2)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              width: 2,
              color: outLined
                ? enabled
                  ? color
                  : color.withOpacity(0.2)
                : Colors.transparent,
        )
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
