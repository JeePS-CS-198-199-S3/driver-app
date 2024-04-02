import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../menu_controller.dart';
import '../models/account_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';
import 'jeeps_list_widget.dart';

class Header extends StatelessWidget {
  final AccountData driverAccount;
  final RouteData? routeData;
  const Header({Key? key, required this.driverAccount, required this.routeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
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
        ),

        if (routeData != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Route: ${routeData!.routeName}"),
              const SizedBox(width: Constants.defaultPadding / 4, height: 50),
              Icon(Icons.circle, color: Color(routeData!.routeColor), size: 15)
            ],
          ),
      ],
    );
  }
}
