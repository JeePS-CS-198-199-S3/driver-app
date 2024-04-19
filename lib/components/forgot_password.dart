import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/primary_text.dart';
import 'package:transitrack_driver/components/square_loader.dart';

import '../style/constants.dart';
import 'button.dart';
import 'text_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // text editing controllers
  final emailController = TextEditingController();

  bool verifSent = false;

  void sendVerification() async {
    Loader(context);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);

      Navigator.of(context).pop();
      setState(() {
        verifSent = true;
      });
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          width: 500,
          padding: const EdgeInsets.only(
              left: Constants.defaultPadding,
              right: Constants.defaultPadding,
              bottom: Constants.defaultPadding),
          body: Text(e.toString()))
          .show();
    }
  }

  void changeEmail() {
    setState(() {
      emailController.clear();
      verifSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            left: Constants.defaultPadding,
            right: Constants.defaultPadding,
            bottom: Constants.defaultPadding),
        child: Column(
          children: [
            const Row(
              children: [
                PrimaryText(
                  text: "Reset Password",
                  color: Colors.white,
                  size: 20,
                  fontWeight: FontWeight.w700,
                )
              ],
            ),
            const SizedBox(height: Constants.defaultPadding),
            if (!verifSent)
              InputTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false),
            if (verifSent)
              Text(
                "We have sent an email to\n\n${emailController.text}\n\nPlease check your inbox/spam folder to proceed with your password reset.",
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: Constants.defaultPadding * 2),
            Button(
              onTap: verifSent ? changeEmail : sendVerification,
              widget: Text(verifSent ? "Change Email" : "Send Verification Code"),
            ),
          ],
        ));
  }
}
