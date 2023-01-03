import 'package:flutter/material.dart';

import '../objects/user_info.dart';

// Column that contains member's full name and username
class UserIdentifier extends StatelessWidget {
  const UserIdentifier(
      {super.key,
      required this.user,
      this.bottomPadding = 0,
      this.fontWeight = FontWeight.bold,
      this.crossAxis = CrossAxisAlignment.center,
      this.mainAxis = MainAxisAlignment.center});

  final UserInfo user;
  final FontWeight fontWeight;
  final CrossAxisAlignment crossAxis;
  final MainAxisAlignment mainAxis;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
            mainAxisAlignment: mainAxis,
            crossAxisAlignment: crossAxis,
            children: [
              Text(user.m_full_name,
              overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: fontWeight)),
              Text("@${user.m_username}")
            ]));
  }
}
