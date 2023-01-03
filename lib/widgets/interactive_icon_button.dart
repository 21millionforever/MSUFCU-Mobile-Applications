import 'package:flutter/material.dart';

import '../msufcu_color_scheme.dart';

class InteractiveIconButton extends StatefulWidget {
  const InteractiveIconButton(
      {super.key,
      required this.icon,
      required this.iconSize,
      required this.onPressed,
      required this.selected});

  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final bool selected;

  @override
  State<InteractiveIconButton> createState() => _InteractiveIconButtonState();
}

class _InteractiveIconButtonState extends State<InteractiveIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
        onPressed: widget.onPressed,
        isSelected: widget.selected,
        iconSize: widget.iconSize,
        color: msufcuForestGreen,
        icon: Icon(widget.icon, color: msufcuMediumGrey),
        selectedIcon: Icon(widget.icon, color: msufcuForestGreen));
  }
}
