import 'package:flutter/material.dart';

import '../msufcu_color_scheme.dart';

class InteractiveTextButton extends StatefulWidget {
  const InteractiveTextButton(
      {super.key,
      required this.title,
      required this.fontSize,
      required this.onPressed,
      required this.selected});

  final String title;
  final double fontSize;
  final VoidCallback onPressed;
  final bool selected;

  @override
  State<InteractiveTextButton> createState() => _InteractiveTextButtonState();
}

class _InteractiveTextButtonState extends State<InteractiveTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0), minimumSize: const Size(20, 20)),
        child: Text(
          widget.title,
          style: TextStyle(fontSize: widget.fontSize, color: widget.selected ? msufcuForestGreen : msufcuMediumGrey),
          textWidthBasis: TextWidthBasis.longestLine,
        ));
  }
}
