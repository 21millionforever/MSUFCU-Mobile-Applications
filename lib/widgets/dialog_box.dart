import 'package:flutter/material.dart';

import '../msufcu_color_scheme.dart';

class CustomDialogBox extends StatelessWidget {
  const CustomDialogBox(
      {super.key,
      required this.title,
      required this.content,
      required this.button});

  final String title;
  final String content;
  final String button;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          //test
          style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: msufcuForestGreen),
          child: Text(button),
        ),
      ],
    );
  }
}