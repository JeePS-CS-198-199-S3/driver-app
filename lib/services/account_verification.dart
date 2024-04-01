import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:transitrack_driver/models/account_model.dart';

void checkAccountType(BuildContext context, AccountData driverAccount) {
  if (driverAccount.account_type != 1) {
    Future.delayed(const Duration(seconds: 1), () {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        desc: 'This app is only intended for the JeePS drivers. Please use a driver account.',
        onDismissCallback: (_) => FirebaseAuth.instance.signOut(),
      ).show();
    });
  } else if (!driverAccount.is_verified) {
    Future.delayed(const Duration(seconds: 1), () {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        desc: 'This app is only intended for verified JeePS drivers. Contact your route manager for account verification.',
        onDismissCallback: (_) => FirebaseAuth.instance.signOut(),
      ).show();
    });
  }
}