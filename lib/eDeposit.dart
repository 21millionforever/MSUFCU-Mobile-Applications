// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/objects/user_info.dart';
import 'local_loyalty_recommend.dart';
import 'msufcu_color_scheme.dart';

class eDepositText extends StatefulWidget {
  final UserInfo loggedInUser;
  const eDepositText({super.key, required this.loggedInUser});

  @override
  State<eDepositText> createState() => _eDepositTextState();
}

class _eDepositTextState extends State<eDepositText> {
  String text = "5";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Local Loyalty Text",
        theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            fontFamily: 'OpenSans'),
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => {Navigator.of(context).pop()}),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text("Local Loyalty Text"),
            centerTitle: true,
          ),
          body: Text(text),
        ));
  }
}

/// This is just a palceholder eDeposit page that represents the eDeposit page in the MSUFCU app
/// Has no functionality
class eDeposit extends StatefulWidget {
  final UserInfo loggedInUser;
  const eDeposit({super.key, required this.loggedInUser});

  @override
  eDepositWidget createState() {
    return eDepositWidget();
  }
}

String text = "";

class eDepositWidget extends State<eDeposit> {
  String toUpdate = "";
  eDepositWidget();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "eDeposit",
        theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            fontFamily: 'OpenSans'),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text("eDeposit"),
            centerTitle: true,
          ),
          body: Column(children: <Widget>[
            Center(
              child: TextButton(
                  onPressed: () {
                    LLR(widget.loggedInUser);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: msufcuForestGreen,
                    shadowColor: Colors.grey,
                    elevation: 5,
                  ),
                  child: const Text("I Agree")),
            ),
            Text(toUpdate),
          ]),
        ));
  }

  void LLR(UserInfo loggedInUser) async {
    LLRecommend llRecommend = LLRecommend();
    text = await llRecommend.get_LLRecommend(loggedInUser);
    setState(() {
      toUpdate = "You have agreed";
    });
  }
}
