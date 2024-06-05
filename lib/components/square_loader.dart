import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../style/constants.dart';

// Loader UI called when performing async operations

void Loader(BuildContext context) {
  AwesomeDialog(context: context, dialogType: DialogType.noHeader, width: 150, padding: EdgeInsets.only(bottom: Constants.defaultPadding), body: const Center(child: CircularProgressIndicator()), dismissOnTouchOutside: false).show();
}