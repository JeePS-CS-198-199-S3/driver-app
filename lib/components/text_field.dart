import 'package:flutter/material.dart';

import '../style/constants.dart';

class InputTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const InputTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.white
            )
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Constants.primaryColor
            )
        ),
        fillColor: Constants.secondaryColor,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white)
      ),
    );
  }
}