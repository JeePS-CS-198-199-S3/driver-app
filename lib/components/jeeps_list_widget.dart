import 'package:flutter/material.dart';
import 'package:transitrack_driver/models/account_model.dart';

import '../models/jeep_driver_model.dart';
import '../models/jeep_model.dart';

class JeepsListWidget extends StatelessWidget {
  AccountData accountData;
  JeepsListWidget({
    super.key,
    required this.accountData
  });

  void updateDriverJeep(String plateNumber) async {
    await AccountData.updateAccountFirestore(accountData.account_email, {'jeep_driving': plateNumber});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchJeeps(),
      builder: (BuildContext context,
          AsyncSnapshot<List<JeepDriverData>> snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<JeepDriverData> jeepDriverData = snapshot.data!;

        return ListView.builder(
            shrinkWrap: true,
            itemCount: jeepDriverData.length,
            itemBuilder: (context, index) {
              JeepDriverData jeepDriver = jeepDriverData[index];
              return ListTile(
                leading: Icon(Icons.circle, color: Color(jeepDriver.routeData.routeColor)),
                title: Text(jeepDriver.jeepData.device_id),
                subtitle: Text(jeepDriver.driverData != null?jeepDriver.driverData!.account_name:"Vacant"),
                onLongPress: () {
                  updateDriverJeep(jeepDriver.jeepData.device_id);
                  Navigator.of(context).pop();
                },
                dense: true,
                visualDensity: VisualDensity.compact,
                splashColor: Color(jeepDriver.routeData.routeColor).withOpacity(0.2),
                enabled: jeepDriver.driverData == null,
              );
            });
      },
    );
  }
}