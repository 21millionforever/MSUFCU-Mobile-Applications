import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/send_money.dart';

import '../objects/user_info.dart';
import 'send_money_member_card.dart';

/// Creates a scrollable list containing members connected to the loggedInUser,
/// sorted by whichever filter is currently selected
class ListMembers extends StatefulWidget {
  const ListMembers(
      {super.key,
      required this.loggedInUser,
      this.padding = const EdgeInsets.only(bottom: 8)});

  final UserInfo loggedInUser;
  final EdgeInsetsGeometry padding;

  @override
  State<ListMembers> createState() => _ListMembersState();
}

class _ListMembersState extends State<ListMembers> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: widget.padding,
            child: ValueListenableBuilder(
                builder: (BuildContext context, List<UserInfo> value,
                    Widget? child) {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: displayedUsers.value.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                            height: 50,
                            child: MemberCard(
                              user: displayedUsers.value[index],
                              loggedInUser: widget.loggedInUser,
                            ));
                      });
                },
                valueListenable: displayedUsers)));
  }
}
