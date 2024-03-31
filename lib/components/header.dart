import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../menu_controller.dart';
import '../models/account_model.dart';
import '../style/constants.dart';
import 'jeeps_list_widget.dart';

class Header extends StatelessWidget {
  final AccountData driverAccount;
  const Header({Key? key, required this.driverAccount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: context.read<MenuControllers>().controlMenu,
            icon: const Icon(Icons.menu, size: 35)
        ),

        IconButton(
            onPressed: () {
              AwesomeDialog(
                  context: context,
                  keyboardAware: false,
                  dialogType: DialogType.noHeader,
                  body: JeepsListWidget(accountData: driverAccount)
              ).show();
            },
            icon: const Text("PUV LIST"),
            iconSize: 17,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding)
        )
      ],
    );
  }
}
