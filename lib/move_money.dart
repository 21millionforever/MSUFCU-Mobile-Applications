// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/recievePage.dart';
import 'package:msufcu_flutter_project/transaction_history.dart';
import 'package:msufcu_flutter_project/send_money.dart';
import 'Classes/transactionHistory.dart';
import 'objects/user_info.dart';

/// Global variable that holds the transaction history
List<transactionHistory> history = [];

// Builds the section that holds the tabs for the Send, Receive, and History pages
class HelloWorld extends StatelessWidget {
  const HelloWorld({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Hello World Page",
        theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            fontFamily: 'OpenSans'),
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    title: const Text("MemberToMember™"),
                    centerTitle: true,
                    bottom: TabBar(
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black,
                      tabs: const [
                        Tab(text: 'Send'),
                        Tab(text: 'Receive'),
                        Tab(text: 'History')
                      ],
                    )),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SendMoney(
                      loggedInUser: loggedInUser,
                    ),
                    RecievePage(
                      loggedInUser: loggedInUser,
                    ),
                    TransactionHistory(loggedInUser: loggedInUser),
                  ],
                ),
                resizeToAvoidBottomInset: false)));
  }
}
