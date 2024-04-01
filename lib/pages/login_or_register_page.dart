import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/pages/register_page.dart';
import 'login_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages
      );
    } else {
      return RegisterPage(
        onTap: togglePages);
    }
  }
}
