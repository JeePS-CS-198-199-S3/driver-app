import 'package:flutter/material.dart';

class ImageButtonBig extends StatelessWidget {
  String imagePath;
  Color color;
  Function function;
  bool enabled;
  ImageButtonBig({
    super.key,
    required this.imagePath,
    required this.color,
    required this.function,
    required this.enabled
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => enabled
        ? function()
        : null
      ,
      child: Container(
        decoration: BoxDecoration(
            color: enabled? color:color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0)
        ),
        width: 73,
        height: 73,
        child: Opacity(
          opacity: enabled? 1:0.2,
          child: Image.asset(imagePath, fit: BoxFit.cover)),
      ),
    );
  }
}
