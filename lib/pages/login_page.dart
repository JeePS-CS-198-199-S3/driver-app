import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/components/button.dart';
import 'package:transitrack_driver/components/square_tile.dart';

import '../components/text_field.dart';
import '../services/auth_service.dart';
import '../style/constants.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {

    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    // try sign in
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );

      // pop loading circle
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      // pop loading circle
      Navigator.pop(context);
      errorMessage(e.code);
    }
  }

  void errorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Constants.bgColor,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white
              ),
            )
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
            child: SingleChildScrollView(
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
              
                  Button(onTap: signUserIn, text: "Sign In",),

                  const SizedBox(height: Constants.defaultPadding*2.5),

                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Constants.defaultPadding*2.5),

                  SquareTile(imagePath: 'lib/images/google.png', onTap: () async {
                    UserCredential? userCredential = await AuthService().signInWithGoogle();
                    AuthService().createUserDocument(userCredential?.user);
                    }
                  ),

                  const SizedBox(height: Constants.defaultPadding*2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Register now',
                          style: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


