import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/map_widget.dart';
import '../models/account_model.dart';
import '../models/jeep_model.dart';

class DashboardPage extends StatefulWidget {
  final AccountData driverAccount;
  const DashboardPage({super.key, required this.driverAccount});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late AccountData _driverAccount;
  JeepData? driverJeep;

  @override
  void initState() {
    super.initState();

    setState(() {
      _driverAccount = widget.driverAccount;
    });

    checkAccountType();
  }


  @override void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_driverAccount != widget.driverAccount) {

      // Save previous driverAccount state
      AccountData prev = _driverAccount;

      setState(() {
        _driverAccount = widget.driverAccount;
      });

      // Check if we have changes in the jeep_driving field so we can load the latest jeepData.
      if (prev.jeep_driving != _driverAccount.jeep_driving) {
        fetchJeep();
      }
    }
  }

  void checkAccountType() {
    if (widget.driverAccount.account_type != 1) {
      Future.delayed(const Duration(seconds: 1), () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          desc: 'This app is only intended for the JeePS drivers. Please use a driver account.',
          onDismissCallback: (_) => FirebaseAuth.instance.signOut(),
        ).show();
      });
    }
  }

  void fetchJeep() async {
    if (_driverAccount.jeep_driving != "") {
      JeepData? jeepData = await fetchJeepData(_driverAccount.jeep_driving!);

      setState(() {
        driverJeep = jeepData;
      });
    } else {
      setState(() {
        driverJeep = null;
      });
    }

  }



  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Expanded(
            child: MapWidget(),
          ),
          SizedBox(height: 250)
        ],
      )
    );
  }
}




