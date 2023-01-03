import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/msufcu_color_scheme.dart';

// Creates a button with a parameter to fill the title
class InteractiveButton extends StatelessWidget {
  const InteractiveButton(
      {super.key,
      required this.title,
      this.width = 200,
      required this.onPressed});

  final String title;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)))),
              backgroundColor:
                  MaterialStateProperty.all<Color>(msufcuForestGreen)),
          onPressed: onPressed,
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 20))),
    );
  }
}
