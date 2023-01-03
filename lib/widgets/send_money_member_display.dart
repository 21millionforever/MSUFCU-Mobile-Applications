import 'package:flutter/material.dart';
import 'package:msufcu_flutter_project/send_money.dart';

import 'interactive_icon_button.dart';
import 'interactive_text_button.dart';
import '../objects/user_info.dart';
import 'send_money_list_members.dart';

/// Creates the widget that contains filter selectors, a divider,
/// and a scrollable list of members
// ignore: must_be_immutable
class MemberDisplay extends StatefulWidget {
  MemberDisplay({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;
  final ValueNotifier<List<UserInfo>> displayedUsers =
      getDisplayedUsersNotifier();

  @override
  State<MemberDisplay> createState() => _MemberDisplayState();
}

class _MemberDisplayState extends State<MemberDisplay> {
  /// Notifier of an int that signifies which sorting button is currently selected
  final ValueNotifier<int> sortType = getSortTypeNotifier();

  @override
  Widget build(BuildContext context) {
    bool replaceWithIcon = MediaQuery.of(context).size.width < 340;
    return Expanded(
        child: FractionallySizedBox(
            widthFactor: 1,
            child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: ValueListenableBuilder(
                      builder:
                          (BuildContext context, int value, Widget? child) {
                        return Column(children: [
                          SizedBox(
                              height: 30,
                              child: Row(children: [
                                const Text("Sort By:",
                                    style: TextStyle(fontSize: 20)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(children: [
                                    replaceWithIcon
                                        ? InteractiveIconButton(
                                            selected: sortType.value == 0
                                                ? true
                                                : false,
                                            icon: Icons.star,
                                            iconSize: 28,
                                            onPressed: (() => {
                                                  setState(() {
                                                    sortType.value = 0;
                                                  }),
                                                  sortUsers()
                                                }),
                                          )
                                        : InteractiveTextButton(
                                            selected: sortType.value == 0
                                                ? true
                                                : false,
                                            title: "Favorites",
                                            fontSize: 20,
                                            onPressed: (() => {
                                                  setState(() {
                                                    sortType.value = 0;
                                                  }),
                                                  sortUsers()
                                                })),
                                    const VerticalDivider(
                                        width: 10,
                                        thickness: 2.0,
                                        color: Colors.black,
                                        indent: 5,
                                        endIndent: 5),
                                    InteractiveTextButton(
                                        selected:
                                            sortType.value == 1 ? true : false,
                                        title: "A-Z",
                                        fontSize: 20,
                                        onPressed: () => {
                                              setState(() {
                                                sortType.value = 1;
                                              }),
                                              sortUsers()
                                            }),
                                    const VerticalDivider(
                                        width: 10,
                                        thickness: 2.0,
                                        color: Colors.black,
                                        indent: 5,
                                        endIndent: 5),
                                    replaceWithIcon
                                        ? InteractiveIconButton(
                                            icon: Icons.timer,
                                            iconSize: 28,
                                            onPressed: () => {
                                                  setState(() {
                                                    sortType.value = 2;
                                                  }),
                                                  sortUsers()
                                                },
                                            selected: sortType.value == 2
                                                ? true
                                                : false)
                                        : InteractiveTextButton(
                                            selected: sortType.value == 2
                                                ? true
                                                : false,
                                            title: "Recent",
                                            fontSize: 20,
                                            onPressed: () => {
                                              setState(() {
                                                sortType.value = 2;
                                              }),
                                              sortUsers()
                                            },
                                          )
                                  ]),
                                )
                              ])),
                          const Divider(color: Colors.grey, thickness: 5.0),
                          ListMembers(loggedInUser: widget.loggedInUser)
                        ]);
                      },
                      valueListenable: sortType,
                    )))));
  }
}
