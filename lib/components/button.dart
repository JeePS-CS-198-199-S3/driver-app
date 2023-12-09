import 'package:flutter/cupertino.dart';

import '../style/constants.dart';

class Button extends StatelessWidget {

  final Function()? onTap;

  const Button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.circular(8)
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Constants.defaultPadding),
            child: Text(
              "Sign In",
              style: TextStyle(
                color: Constants.bgColor,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
        ),
      ),
    );
  }
}
