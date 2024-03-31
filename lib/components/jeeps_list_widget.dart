import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_driver/components/square_loader.dart';
import 'package:transitrack_driver/models/account_model.dart';

import '../models/jeep_driver_model.dart';
import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class JeepsListWidget extends StatefulWidget {
  AccountData accountData;
  JeepsListWidget({
    super.key,
    required this.accountData
  });

  @override
  State<JeepsListWidget> createState() => _JeepsListWidgetState();
}

class _JeepsListWidgetState extends State<JeepsListWidget> {
  List<RouteData>? routes;

  // For searching function
  TextEditingController searchController = TextEditingController();
  String searchString = "";
  List<int> showRoutes = [];
  bool showOccupiedPUV = true;

  // Loading jeeps
  List<JeepDriverData>? jeepDriverData;

  @override
  void initState() {
    super.initState();

    loadRoutes();
  }

  Future<void> loadRoutes() async {
    setState(() {
      routes = null;
    });

    List<RouteData>? data = await RouteData.fetchRoutes();

    setState(() {
      routes = data;
      showRoutes = routes!.map((e) => e.routeId).toList();
    });

    loadJeeps();
  }

  Future<void> loadJeeps() async {
    setState(() {
      jeepDriverData = null;
    });

    List<JeepDriverData>? data = await fetchJeeps();

    setState(() {
      jeepDriverData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (routes == null || jeepDriverData == null) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
            child: Column(
              children: [
                SearchBar(
                  overlayColor: MaterialStateProperty.all(
                      Colors.white.withOpacity(0.2)),
                  elevation: MaterialStateProperty.all(0.0),
                  onChanged: (String value) {
                    setState(() {
                      searchString = value;
                    });
                  },
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  hintText: 'Search Plate Number',
                  hintStyle: MaterialStateProperty.all(
                      const TextStyle(fontSize: 12)),
                  shape: MaterialStateProperty.all(
                      const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                  trailing: <Widget>[
                    Row(
                      children: [
                        IconButton(
                            onPressed: () => loadRoutes(),
                            icon: const Icon(Icons.refresh),
                            iconSize: 17,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero
                        ),
                        IconButton(
                          iconSize: 17,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          onPressed: () => AwesomeDialog(
                            dialogType: DialogType.noHeader,
                            context: (context),
                            body: JeepListFilterSettings(
                                currentSettings: JeepListSettings(
                                    showOccupiedPUV: showOccupiedPUV,
                                    showRoutes: { for (RouteData route in routes!) route : showRoutes.contains(route.routeId) }),
                                newSettings: (JeepListSettings newSettings) {
                              setState(() {
                                showOccupiedPUV = newSettings.showOccupiedPUV;
                                showRoutes = newSettings.showRoutes.entries
                                    .where((entry) => entry.value == true)
                                    .map((entry) => entry.key.routeId)
                                    .toList();
                              });
                              }
                            ),
                          ).show(),
                          icon: const Icon(Icons.filter_list),
                        )
                      ],
                    )
                  ],
                ),
                const Divider(color: Colors.white),
              ],
            ),
          ),

          SizedBox(
            height: 300,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: jeepDriverData!.length,
                itemBuilder: (context, index) {
                  JeepDriverData jeepDriver = jeepDriverData![index];


                  if (searchString.isNotEmpty
                      && !jeepDriver.jeepData.device_id.toLowerCase().contains(searchString.toLowerCase())
                  ) {
                    return const SizedBox();
                  }

                  if (!showOccupiedPUV && jeepDriver.driverData != null) {
                    return const SizedBox();
                  }

                  if (!showRoutes.contains(jeepDriver.jeepData.route_id)) {
                    return const SizedBox();
                  }



                  return ListTile(
                    leading: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              width: 3,
                              color: Color(routes![jeepDriver.jeepData.route_id].routeColor)
                          )
                      ),
                      child: Center(child: Text(jeepDriver.jeepData.max_capacity.toString(), style: const TextStyle(fontSize: 10))),
                    ),
                    title: Text(jeepDriver.jeepData.device_id),
                    subtitle: Text(jeepDriver.driverData != null
                        ? jeepDriver.driverData!.account_email == widget.accountData.account_email
                        ? "YOU"
                        : "Occupied"
                        : "Vacant"),
                    trailing: Text(routes![jeepDriver.jeepData.route_id].routeName),
                    onLongPress: () {
                      Loader(context);
                      updateDriverJeep(widget.accountData.account_email, {"jeep_driving": jeepDriver.jeepData.device_id});
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                    },
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    splashColor: Color(routes![jeepDriver.jeepData.route_id].routeColor).withOpacity(0.2),
                    enabled: jeepDriver.driverData == null,
                  );
                }),
          ),

          const SizedBox(height: Constants.defaultPadding)
        ],
      );
    }
  }
}

class JeepListSettings {
  bool showOccupiedPUV;
  Map<RouteData, bool> showRoutes;

  JeepListSettings({
    required this.showOccupiedPUV,
    required this.showRoutes
  });
}

class JeepListFilterSettings extends StatefulWidget {
  final JeepListSettings currentSettings;
  final ValueChanged<JeepListSettings> newSettings;
  const JeepListFilterSettings({
    super.key,
    required this.currentSettings,
    required this.newSettings
  });

  @override
  State<JeepListFilterSettings> createState() => _JeepListFilterSettingsState();
}

class _JeepListFilterSettingsState extends State<JeepListFilterSettings> {
  late bool _showOccupiedPUV;
  late Map<RouteData, bool> _showRoutes;
  late List<RouteData> routes;
  late List<bool> show;

  @override
  void initState() {
    super.initState();

    setState(() {
      _showOccupiedPUV = widget.currentSettings.showOccupiedPUV;
      _showRoutes = widget.currentSettings.showRoutes;
      routes = _showRoutes.keys.toList();
      show = _showRoutes.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Constants.defaultPadding, bottom: Constants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextAndCheckboxWidget(text: "Show Occupied PUV", size: 17, state: _showOccupiedPUV, color: Colors.white, update: () => setState(() {_showOccupiedPUV = !_showOccupiedPUV;})),

          const Divider(color: Colors.white),

          const SizedBox(height: Constants.defaultPadding),

          const Text("Show Routes", style: TextStyle(fontSize: 17),),

          SizedBox(
            height: 150,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _showRoutes.length,
              itemBuilder: (context, index) {
                return TextAndCheckboxWidget(text: routes[index].routeName, state: show[index], color: Color(routes[index].routeColor), update: () => setState(() {
                  show[index] = !show[index];
                }));
              }
            ),
          ),

          SizedBox(
            width: double.maxFinite,
            child: IconButton(
              onPressed: () {
                widget.newSettings(JeepListSettings(showOccupiedPUV: _showOccupiedPUV, showRoutes: { for (RouteData route in routes) route : show[route.routeId] }));

                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save)
            ),
          )
        ],
      ),
    );
  }
}

class TextAndCheckboxWidget extends StatefulWidget {
  final String text;
  final double size;
  final bool state;
  final Function update;
  final Color color;
  const TextAndCheckboxWidget({super.key,
    this.size = 13,
    required this.text,
    required this.state,
    required this.update,
    required this.color
  });

  @override
  State<TextAndCheckboxWidget> createState() => _TextAndCheckboxWidgetState();
}

class _TextAndCheckboxWidgetState extends State<TextAndCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            widget.text,
          style: TextStyle(fontSize: widget.size),
        ),
        IconButton(onPressed: () => widget.update(),
            icon: Icon(widget.state
                ? Icons.circle
                : Icons.circle_outlined,
            color: widget.color,
            size: 20,
          )
        )
      ],
    );
  }
}
