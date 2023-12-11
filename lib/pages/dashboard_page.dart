import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../style/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
          child: Column(
            children: [
              Text(
                "Logged in as ${user.email}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14
                )
              ),

              const SizedBox(height: Constants.defaultPadding*4),

              Text(
                  "4/16",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 75,
                    fontWeight: FontWeight.bold
                  )
              ),
              Text(
                  "passengers",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  )
              ),

              const SizedBox(height: Constants.defaultPadding*4),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2
                        ),
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.green[900]
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                 const SizedBox(width: Constants.defaultPadding),

                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white,
                              width: 2
                          ),
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.red[900]
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Constants.defaultPadding),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Constants.secondaryColor,
                          borderRadius: BorderRadius.circular(24)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Plate Number: ABC123", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text("Route: Ikot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(width: 5),
                                Icon(Icons.circle, color: Colors.yellow, size:13)
                              ],
                            ),
                            Text("Fare: PHP 10.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: Constants.defaultPadding),
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Constants.secondaryColor,
                                  borderRadius: BorderRadius.circular(24)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Operate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Stack(children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Constants.bgColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: SizedBox(width: 60, height: 30),
                                    ),
                                    Icon(Icons.circle, color: Colors.green, size: 30),
                                  ]),
                                ],
                              )
                          ),
                        ),
                        SizedBox(height: Constants.defaultPadding),
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  borderRadius: BorderRadius.circular(24)
                              ),
                              child: Center(child: Text("SOS!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
