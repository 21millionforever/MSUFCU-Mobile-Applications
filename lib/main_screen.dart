import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/accounts.dart';
import 'package:msufcu_flutter_project/eDeposit.dart';
import 'package:msufcu_flutter_project/move_money.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';
import 'package:msufcu_flutter_project/my_offers_screen.dart';
import 'objects/user_info.dart';

/// Builds the main screen that allows for navagation between the different tabs seen on the bottom of the page
class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            fontFamily: 'OpenSans'),
        home: DefaultTabController(
          length: 4,
          child: Scaffold(

              // Container for tab bar and included box shadow
              bottomNavigationBar: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: msufcuMediumGrey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3))
                  ]),

                  // Tab bar containing different navigation tabs
                  child: const TabBar(
                    labelColor: msufcuForestGreen,
                    unselectedLabelColor: msufcuMediumGrey,
                    indicatorColor: Colors.transparent,
                    tabs: [
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.contain, child: Text("Accounts"))),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text("MoveMoney\u2120"))),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.contain, child: Text("eDeposit"))),
                      Tab(
                          child: FittedBox(
                              fit: BoxFit.contain, child: Text("My Offers")))
                    ],
                  )),

              // TabBarView displaying different images when different tabs are selected
              body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Accounts(loggedInUser),
                  HelloWorld(loggedInUser: loggedInUser),
                  eDeposit(loggedInUser: loggedInUser),
                  MyOffers(loggedInUser: loggedInUser)
                ],
              )),
        )
        ));
  }
}
