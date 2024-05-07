import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/button.dart';

import '../components/text_field.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<RouteData>? routes;
  List<String>? names;
  String? chosenRoute;

  @override
  void initState() {
    super.initState();

    fetchRoutes();
  }

  void fetchRoutes() async {
    List<RouteData>? data = await RouteData.fetchRoutes();

    setState(() {
      routes = data;
      names = routes!.map((e) => e.routeName).toList();
      chosenRoute = names!.first;
    });
  }

  // text editing controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user in method
  void signUserUp() async {

    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    // try sign up
    try {
      if (nameController.text.isNotEmpty) {
        // check if password is confirmed
        if (passwordController.text == confirmPasswordController.text) {
           if (routes != null && chosenRoute != null) {
             await FirebaseAuth.instance.createUserWithEmailAndPassword(
                 email: emailController.text, password: passwordController.text).then((value) async {
               Navigator.pop(context);
               await FirebaseFirestore.instance
                   .collection('accounts')
                   .add({
                 'account_name': nameController.text,
                 'account_email': emailController.text,
                 'account_type': 1,
                 'jeep_driving': "",
                 'is_verified': false,
                 'route_id': routes!.firstWhere((element) =>
                 element.routeName == chosenRoute!).routeId,
               });
             });
           } else {
             // password dont match
             errorMessage("Select a route you wish to associate to.");
           }
        } else {
          // pop loading circle
          Navigator.pop(context);

          // password dont match
          errorMessage("Passwords don't match!");
        }
      } else {
        // pop loading circle
        Navigator.pop(context);

        // password dont match
        errorMessage("Name is required!");
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
                style: const TextStyle(color: Colors.white),
              )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Constants.defaultPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('lib/images/logo.png'),
                    height: 100,
                  ),
                  const SizedBox(height: Constants.defaultPadding * 1),
                  const Text(
                    "Let's create an account for you!",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: Constants.defaultPadding * 2),
                  const Divider(
                    height: 1,
                    color: Color.fromARGB(102, 158, 158, 158),
                  ),
                  const SizedBox(height: Constants.defaultPadding * 2),
                  InputTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false),
                  const SizedBox(height: Constants.defaultPadding / 2),
                  InputTextField(
                      controller: nameController,
                      hintText: "Name",
                      obscureText: false),
                  const SizedBox(height: Constants.defaultPadding / 2),
                  InputTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true),
                  const SizedBox(height: Constants.defaultPadding / 2),
                  InputTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true),
                  const SizedBox(height: Constants.defaultPadding / 2),

                  if (names == null)
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding/2, vertical: Constants.defaultPadding + 2.5),
                    decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: Colors.white, // Set border color here
                        width: 1, // Set border width here
                      ),
                    ),
                    child: Text("Loading Routes...", style: TextStyle(fontSize: 15),),
                  ),

                  if (names != null)
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding/2, vertical: 4),
                    decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: Colors.white, // Set border color here
                        width: 1, // Set border width here
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: chosenRoute, // Initial value
                        onChanged: (String? newValue) {
                          // Handle dropdown value change
                          if (newValue != null) {
                            setState(() {
                              chosenRoute = newValue;
                            });
                          }
                        },
                        items: names!.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: Constants.defaultPadding * 2),
                  Button(
                    onTap: signUserUp,
                    widget: const Text("Sign Up"),
                  ),
                  const SizedBox(height: Constants.defaultPadding * 2.5),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  'Login now',
                  style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          )),
    );
  }
}
