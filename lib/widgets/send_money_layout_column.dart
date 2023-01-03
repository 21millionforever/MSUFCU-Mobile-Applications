import 'package:flutter/material.dart';

import '../objects/user_info.dart';
import '../send_money.dart';
import 'send_money_list_members.dart';
import 'send_money_member_display.dart';
import 'send_money_scan_qr.dart';
import 'send_money_search_bar.dart';

class SendMoneyLayoutWithoutSearchBar extends StatelessWidget {
  const SendMoneyLayoutWithoutSearchBar(
      {super.key, required this.loggedInUser});

  final UserInfo loggedInUser;

  /// Makes sure users cannot use searchbar while refreshing the page
  Future<void> refreshPage() async {
    if (!searchingUsers.value) {
      refreshingPage.value = true;
      displayedUsers.value = await getConnectedUsers(loggedInUser);
      refreshingPage.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: RefreshIndicator(
            onRefresh: () => refreshPage(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: 80,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      ScanQR(loggedInUser: loggedInUser),
                      NFC(
                        loggedInUser: loggedInUser,
                      ),
                      Blue(
                        loggedInUser: loggedInUser,
                      ),
                    ])),
                MemberDisplay(loggedInUser: loggedInUser)
              ],
            )));
  }
}

/// Creates the column containing the essential widgets
/// withing the Send Money page
class SendMoneyLayoutColumn extends StatelessWidget {
  SendMoneyLayoutColumn({super.key, required this.loggedInUser});

  final UserInfo loggedInUser;
  final ValueNotifier<bool> searchingUsers = getSearchingUsersNotifier();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SearchBar(loggedInUser: loggedInUser),
        ValueListenableBuilder(
          builder: (BuildContext context, bool value, Widget? child) {
            return searchingUsers.value
                ? Expanded(
                    child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Column(children: [
                          ListMembers(
                              loggedInUser: loggedInUser,
                              padding:
                                  const EdgeInsets.only(bottom: 8, top: 10))
                        ])))
                : SendMoneyLayoutWithoutSearchBar(loggedInUser: loggedInUser);
          },
          valueListenable: searchingUsers,
        )
      ],
    ));
  }
}
