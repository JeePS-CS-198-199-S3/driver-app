import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/components/button.dart';

import '../components/text_field.dart';
import '../style/constants.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.emoji_transportation,
                  size: 100,
                  color: Colors.white,
                ),

                const SizedBox(height: Constants.defaultPadding*3),

                const Text(
                  "Welcome to Transitrack Driver's App!",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),

                const SizedBox(height: Constants.defaultPadding*3),

                InputTextField(controller: emailController, hintText: "Email", obscureText: false),

                const SizedBox(height: Constants.defaultPadding),

                InputTextField(controller: passwordController, hintText: "Password", obscureText: true),

                const SizedBox(height: Constants.defaultPadding/2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.defaultPadding*2),

                Button(onTap: signUserIn),

                const SizedBox(height: Constants.defaultPadding*2),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Register now',
                      style: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


