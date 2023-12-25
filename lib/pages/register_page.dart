import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/components/button.dart';

import '../components/square_tile.dart';
import '../components/text_field.dart';
import '../services/auth_service.dart';
import '../style/constants.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user in method
  void signUserUp() async {

    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator()
          );
        }
    );

    // try sign up
    try{

      // check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );

        // pop loading circle
        Navigator.pop(context);

      } else {

        // pop loading circle
        Navigator.pop(context);

        // password dont match
        errorMessage("Passwords don't match!");

      }


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
                    size: 75,
                    color: Colors.white,
                  ),

                  const SizedBox(height: Constants.defaultPadding*2),

                  const Text(
                    "Let's create an account for you!",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),

                  const SizedBox(height: Constants.defaultPadding*2),

                  InputTextField(controller: emailController, hintText: "Email", obscureText: false),

                  const SizedBox(height: Constants.defaultPadding),

                  InputTextField(controller: passwordController, hintText: "Password", obscureText: true),

                  const SizedBox(height: Constants.defaultPadding),

                  InputTextField(controller: confirmPasswordController, hintText: "Confirm Password", obscureText: true),

                  const SizedBox(height: Constants.defaultPadding/2),

                  const SizedBox(height: Constants.defaultPadding*2),

                  Button(onTap: signUserUp, text: "Sign Up",),

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
                          "Or register with",
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
                        'Already have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Login now',
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


