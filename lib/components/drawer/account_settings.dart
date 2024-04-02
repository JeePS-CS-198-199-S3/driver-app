import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../button.dart';
import '../primary_text.dart';
import '../text_field.dart';

class AccountSettings extends StatelessWidget {
  final AccountData account;
  final RouteData? route;
  const AccountSettings({super.key, required this.account, required this.route});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    nameController.text = account.account_name;

    void errorMessage(String message) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                backgroundColor: Constants.bgColor,
                title: Center(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    )));
          });
    }

    Future<void> deleteAcc() async {
      // Delete the user account in Firebase Authentication
      try {
        await FirebaseAuth.instance.currentUser!.delete();
        print('User account deleted successfully.');
      } catch (e) {
        print('Error deleting user account: $e');
        // Handle the error as needed
      }

      // Delete the corresponding document in Firestore
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('accounts')
            .where('account_email', isEqualTo: account.account_email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
          print('Firestore document deleted successfully.');
        } else {
          print('No document found with the specified email: ${account.account_email}');
        }
      } catch (e) {
        print('Error deleting Firestore document: $e');
        // Handle the error as needed
      }
    }

    void update() async {
      // show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });

      try {
        // check if password is confirmed
        if (nameController.text != account.account_name) {
          Map<String, dynamic> newAccountSettings = {
            'account_name': nameController.text,
          };
          AccountData.updateAccountFirestore(account.account_email, newAccountSettings);
        }

        if (passwordController.text != "" &&
                passwordController.text == confirmPasswordController.text) {
          AccountData.updateEmailAndPassword(
              account.account_email, passwordController.text)
              .then((value) => FirebaseAuth.instance.signOut());
        }

        // pop loading circle
        Navigator.pop(context);
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        Navigator.pop(context);
        errorMessage(e.code);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.defaultPadding,
          right: Constants.defaultPadding,
          bottom: Constants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              PrimaryText(
                text: "Settings",
                color: Colors.white,
                size: 40,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const SizedBox(height: Constants.defaultPadding),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding/2, vertical: Constants.defaultPadding + 2.5),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(account.account_email, style: const TextStyle(fontSize: 15),),
          ),
          const SizedBox(height: Constants.defaultPadding),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding/2, vertical: Constants.defaultPadding + 2.5),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(route?.routeName ?? "Loading Route", style: TextStyle(fontSize: 15),),
          ),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: nameController, hintText: "Name", obscureText: false),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true),
          const SizedBox(height: Constants.defaultPadding),
          InputTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: true),
          const SizedBox(height: Constants.defaultPadding),
          const SizedBox(height: Constants.defaultPadding / 2),
          const PrimaryText(
              text: "Email and password changes will log you out.",
              color: Colors.white),
          const SizedBox(height: Constants.defaultPadding * 2),
          Row(
            children: [
              // Expanded(
              //   child: Button(
              //       onTap: deleteAcc,
              //       widget: const Text("Delete"),
              //     color: Colors.red,
              //   ),
              // ),
              // const SizedBox(width: Constants.defaultPadding),
              Expanded(
                child: Button(
                    onTap: update,
                    widget: const Text("Save")
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
