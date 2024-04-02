import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../models/account_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../primary_text.dart';
import 'account_settings.dart';

class AccountStream extends StatefulWidget {
  AccountData? user;
  String? admin;
  RouteData? route;
  AccountStream(
      {super.key,
        required this.user,
        this.admin,
        required this.route});

  @override
  State<AccountStream> createState() => _AccountStreamState();
}

class _AccountStreamState extends State<AccountStream> {
  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(Constants.defaultPadding),
          margin: const EdgeInsets.symmetric(
              horizontal: Constants.defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            borderRadius: const BorderRadius.all(
                Radius.circular(Constants.defaultPadding)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      PrimaryText(
                          text: widget.user!.account_name,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                      const SizedBox(width: Constants.defaultPadding / 2),
                      Icon(
                          widget.user!.is_verified
                              ? Icons.verified_user
                              : Icons.remove_moderator,
                          color: widget.user!.is_verified
                              ? Colors.blue
                              : Colors.grey,
                          size: 15)
                    ],
                  ),
                  GestureDetector(
                      onTap: () async {
                        AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.noHeader,
                          body: AccountSettings(
                            account: widget.user!,
                            route: widget.route,
                          ),
                        ).show();
                      },
                      child: const Icon(Icons.settings, color: Colors.white))
                ],
              ),

              Text(
                  "${widget.user!.jeep_driving == ""
                      ? "Not operating"
                      : "Operating"} ${AccountData.accountType[widget.user!.account_type]}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
